local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local LevelSelectScreen = {}

local MASCOT_IMAGE = "assets/images/ui/cat-mascot-badge-v1.png"

local function BuildLevelCard(index, level, isUnlocked, isCurrent, onSelect)
    level = level or {}
    local colors = ThemeTokens.colors
    local accent = colors.textMuted
    local background = { 255, 255, 255, 128 }
    local border = { 255, 255, 255, 84 }
    local tubes = level.board and level.board.tubes or {}
    local moveBudget = level.goals and level.goals.bonus and level.goals.bonus.moveBudget or 0
    local title = level.title or "未命名关卡"

    if isUnlocked then
        accent = colors.mistCyan
        background = { 255, 250, 246, 222 }
        border = { 255, 255, 255, 126 }
    end
    if isCurrent then
        accent = colors.mangoGlow
        border = { 255, 198, 108, 122 }
    end

    local children = {
        UI.Label {
            text = string.format("第 %02d 关", index),
            fontSize = ThemeTokens.typography.caption,
            fontColor = isUnlocked and colors.textSecondary or colors.textMuted,
        },
        UI.Label {
            text = title,
            fontSize = ThemeTokens.typography.section,
            fontColor = isUnlocked and colors.textPrimary or colors.textMuted,
        },
    }

    if isUnlocked then
        table.insert(children, UI.Label {
            text = string.format("%d个瓶子  |  目标%d步", #tubes, moveBudget),
            fontSize = ThemeTokens.typography.caption,
            fontColor = colors.textSecondary,
        })
    else
        table.insert(children, UI.Label {
            text = "先完成前面的关卡再来这里。",
            fontSize = ThemeTokens.typography.caption,
            fontColor = colors.textMuted,
        })
    end

    return UI.Panel {
        width = "48%",
        minHeight = 138,
        paddingLeft = 16,
        paddingRight = 16,
        paddingTop = 16,
        paddingBottom = 16,
        gap = 8,
        backgroundColor = background,
        borderRadius = ThemeTokens.radius.card,
        borderWidth = 1,
        borderColor = border,
        boxShadow = isUnlocked and {
            { x = 0, y = 12, blur = 18, spread = 0, color = { 152, 114, 100, 34 } },
        } or nil,
        pointerEvents = isUnlocked and "auto" or "none",
        transition = ThemeTokens.motion.fast,
        onPointerDown = function(event, widget)
            if isUnlocked then
                widget.scale = 0.97
            end
        end,
        onPointerUp = function(event, widget)
            widget.scale = 1.0
            if isUnlocked and onSelect then
                onSelect(index)
            end
        end,
        children = {
            UI.Panel {
                width = 46,
                height = 46,
                borderRadius = 18,
                backgroundColor = { accent[1], accent[2], accent[3], 26 },
                borderWidth = 1,
                borderColor = { accent[1], accent[2], accent[3], 74 },
                justifyContent = "center",
                alignItems = "center",
                children = {
                    UI.Label {
                        text = isUnlocked and tostring(index) or "...",
                        fontSize = ThemeTokens.typography.section,
                        fontColor = accent,
                    },
                },
            },
            UI.Panel {
                gap = 3,
                children = children,
            },
        },
    }
end

function LevelSelectScreen.Create(ctx)
    ctx = ctx or {}
    local chapter = ctx.chapter or {}
    local levels = ctx.levels or {}
    local progress = ctx.progress or {}
    local colors = ThemeTokens.colors
    local totalLevels = #levels
    local currentLevel = totalLevels == 0 and 0 or math.max(1, math.min(progress.currentLevelIndex or 1, totalLevels))
    local unlockedCount = totalLevels == 0 and 0 or math.max(1, math.min(progress.unlockedLevelCount or 1, totalLevels))

    local levelCards = {}
    for index, level in ipairs(levels) do
        table.insert(levelCards, BuildLevelCard(
            index,
            level,
            index <= unlockedCount,
            index == currentLevel,
            function(levelIndex)
                if ctx.onSelectLevel then
                    ctx.onSelectLevel(levelIndex)
                end
            end
        ))
    end

    if #levelCards == 0 then
        table.insert(levelCards, GlassCard {
            width = "100%",
            gap = 8,
            backgroundColor = { 255, 252, 249, 214 },
            children = {
                UI.Label {
                    text = "这里还没有可玩的关卡。",
                    fontSize = ThemeTokens.typography.section,
                    fontColor = colors.textPrimary,
                },
                UI.Label {
                    text = "页面已经做了兜底，不会因为空关卡直接报错。等数据补上后，这里会自动显示卡片。",
                    fontSize = ThemeTokens.typography.body,
                    fontColor = colors.textSecondary,
                },
            },
        })
    end

    local root = UI.Panel {
        width = "100%",
        height = "100%",
        paddingLeft = 14,
        paddingRight = 14,
        paddingTop = 18,
        paddingBottom = 14,
        gap = 12,
        children = {
            DistrictBackdrop {},
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                alignItems = "center",
                children = {
                    UI.Panel {
                        gap = 4,
                        children = {
                            UI.Label {
                                text = "关卡选择",
                                fontSize = ThemeTokens.typography.hero,
                                fontColor = colors.textPrimary,
                            },
                            UI.Label {
                                text = chapter.districtName or "云朵猫镇",
                                fontSize = ThemeTokens.typography.body,
                                fontColor = colors.textSecondary,
                            },
                        },
                    },
                    UI.Panel {
                        width = 82,
                        height = 82,
                        backgroundImage = MASCOT_IMAGE,
                        backgroundFit = "contain",
                    },
                },
            },
            GlassCard {
                backgroundColor = { 255, 250, 246, 220 },
                children = {
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        gap = 10,
                        children = {
                            StatChip {
                                label = "可玩关卡",
                                value = tostring(unlockedCount),
                                valueColor = colors.mistCyan,
                                width = "31%",
                            },
                            StatChip {
                                label = "当前进度",
                                value = currentLevel == 0 and "--" or string.format("%02d", currentLevel),
                                valueColor = colors.coralFizz,
                                width = "31%",
                            },
                            StatChip {
                                label = "乐园氛围",
                                value = "软萌晴天",
                                valueColor = colors.mangoGlow,
                                width = "31%",
                            },
                        },
                    },
                },
            },
            GlassCard {
                flexGrow = 1,
                gap = 12,
                backgroundColor = { 255, 251, 248, 210 },
                children = {
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        justifyContent = "space-between",
                        gap = 10,
                        children = {
                            UI.Label {
                                text = "点选一张关卡卡片，进入猫咪倒水棋盘。",
                                fontSize = ThemeTokens.typography.body,
                                fontColor = colors.textSecondary,
                                width = "65%",
                            },
                            SoftButton {
                                text = "返回地图",
                                width = 110,
                                height = 46,
                                accent = "violet",
                                onClick = function()
                                    if ctx.onBack then
                                        ctx.onBack()
                                    end
                                end,
                            },
                        },
                    },
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        justifyContent = "space-between",
                        gap = 10,
                        children = levelCards,
                    },
                },
            },
        },
    }

    return {
        root = root,
        HandleKey = function(key)
            if key == KEY_ESCAPE and ctx.onBack then
                ctx.onBack()
                return true
            end
            return false
        end,
    }
end

return LevelSelectScreen
