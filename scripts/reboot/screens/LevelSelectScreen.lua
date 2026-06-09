local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local LevelSelectScreen = {}

local MASCOT_IMAGE = "Textures/ui/cat-mascot-badge-v1.png"
local PAGE_SIZE = 8

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

    local subtitle = isUnlocked
        and string.format("%d个瓶子  |  目标%d步", #tubes, moveBudget)
        or "先完成前面的关卡再来这里。"

    return UI.Panel {
        width = "48%",
        minHeight = 136,
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
            UI.Label {
                text = subtitle,
                fontSize = ThemeTokens.typography.caption,
                fontColor = isUnlocked and colors.textSecondary or colors.textMuted,
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
    local chapterIndex = tonumber(ctx.chapterIndex) or 1
    local totalLevels = #levels
    local currentLevel = totalLevels == 0 and 0 or math.max(1, math.min(progress.currentLevelIndex or 1, totalLevels))
    local unlockedCount = totalLevels == 0 and 0
        or math.max(1, math.min((progress.unlockedLevelsByChapter and progress.unlockedLevelsByChapter[chapterIndex]) or 1, totalLevels))
    local maxPage = math.max(1, math.ceil(totalLevels / PAGE_SIZE))
    local pageIndex = maxPage == 0 and 1 or math.max(1, math.min(math.ceil(currentLevel / PAGE_SIZE), maxPage))
    local refs = {}

    local function buildPageCards()
        local cards = {}
        local startIndex = (pageIndex - 1) * PAGE_SIZE + 1
        local finishIndex = math.min(totalLevels, startIndex + PAGE_SIZE - 1)
        for index = startIndex, finishIndex do
            table.insert(cards, BuildLevelCard(
                index,
                levels[index],
                index <= unlockedCount,
                index == currentLevel,
                function(levelIndex)
                    if ctx.onSelectLevel then
                        ctx.onSelectLevel(levelIndex)
                    end
                end
            ))
        end
        return cards, startIndex, finishIndex
    end

    local function refreshPage()
        if not refs.cardsGrid then
            return
        end

        refs.cardsGrid:ClearChildren()
        local cards, startIndex, finishIndex = buildPageCards()
        if #cards == 0 then
            refs.cardsGrid:AddChild(UI.Label {
                text = "这里还没有可玩的关卡。",
                fontSize = ThemeTokens.typography.body,
                fontColor = colors.textSecondary,
            })
        else
            for _, card in ipairs(cards) do
                refs.cardsGrid:AddChild(card)
            end
        end

        if refs.pageValue then
            refs.pageValue:SetText(string.format("第 %d / %d 页", pageIndex, maxPage))
        end
        if refs.rangeValue then
            refs.rangeValue:SetText(string.format("本页关卡：%02d - %02d", startIndex, finishIndex))
        end
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
                                text = chapter.districtName or "猫咪城区",
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
                                label = "当前章节",
                                value = chapter.name or "未命名章节",
                                valueColor = colors.mistCyan,
                                width = "31%",
                            },
                            StatChip {
                                label = "已解锁",
                                value = tostring(unlockedCount),
                                valueColor = colors.coralFizz,
                                width = "31%",
                            },
                            StatChip {
                                label = "主打机制",
                                value = chapter.mechanicFocus or "经典倒水",
                                valueColor = colors.mangoGlow,
                                width = "31%",
                            },
                        },
                    },
                },
            },
            GlassCard {
                gap = 10,
                backgroundColor = { 255, 250, 246, 220 },
                children = {
                    UI.Label {
                        text = chapter.mechanicSummary or "点选一张关卡卡片，进入猫咪倒水棋盘。",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = colors.textSecondary,
                    },
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        justifyContent = "space-between",
                        alignItems = "center",
                        children = {
                            UI.Label {
                                id = "rangeValue",
                                text = "本页关卡：--",
                                fontSize = ThemeTokens.typography.caption,
                                fontColor = colors.textSecondary,
                            },
                            UI.Label {
                                id = "pageValue",
                                text = "第 1 / 1 页",
                                fontSize = ThemeTokens.typography.caption,
                                fontColor = colors.mangoGlow,
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
                            SoftButton {
                                text = "上一页",
                                width = 102,
                                height = 46,
                                accent = "violet",
                                onClick = function()
                                    pageIndex = math.max(1, pageIndex - 1)
                                    refreshPage()
                                end,
                            },
                            SoftButton {
                                text = "返回地图",
                                width = 118,
                                height = 46,
                                accent = "warm",
                                onClick = function()
                                    if ctx.onBack then
                                        ctx.onBack()
                                    end
                                end,
                            },
                            SoftButton {
                                text = "下一页",
                                width = 102,
                                height = 46,
                                accent = "mint",
                                onClick = function()
                                    pageIndex = math.min(maxPage, pageIndex + 1)
                                    refreshPage()
                                end,
                            },
                        },
                    },
                    UI.Panel {
                        id = "cardsGrid",
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        justifyContent = "space-between",
                        gap = 10,
                    },
                },
            },
        },
    }

    refs.cardsGrid = root:FindById("cardsGrid")
    refs.pageValue = root:FindById("pageValue")
    refs.rangeValue = root:FindById("rangeValue")
    refreshPage()

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
