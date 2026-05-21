local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local LevelSelectScreen = {}

local function BuildLevelCard(index, level, isUnlocked, isCurrent, onSelect)
    local accent = ThemeTokens.colors.textMuted
    local background = { 255, 255, 255, 10 }
    local border = { 255, 255, 255, 18 }

    if isUnlocked then
        accent = ThemeTokens.colors.mistCyan
        background = ThemeTokens.colors.cardFog
        border = { 106, 236, 255, 36 }
    end
    if isCurrent then
        accent = ThemeTokens.colors.mangoGlow
        border = { 255, 191, 84, 76 }
    end

    local children = {
        UI.Label {
            text = string.format("Level %02d", index),
            fontSize = ThemeTokens.typography.caption,
            fontColor = isUnlocked and ThemeTokens.colors.textSecondary or ThemeTokens.colors.textMuted,
        },
        UI.Label {
            text = level.title,
            fontSize = ThemeTokens.typography.section,
            fontColor = isUnlocked and ThemeTokens.colors.textPrimary or ThemeTokens.colors.textMuted,
        },
    }

    if isUnlocked then
        table.insert(children, UI.Label {
            text = string.format("%d tubes  |  target %d", #level.board.tubes, level.goals.bonus.moveBudget),
            fontSize = ThemeTokens.typography.caption,
            fontColor = ThemeTokens.colors.textSecondary,
        })
    else
        table.insert(children, UI.Label {
            text = "Unlock by clearing earlier levels.",
            fontSize = ThemeTokens.typography.caption,
            fontColor = ThemeTokens.colors.textMuted,
        })
    end

    return UI.Panel {
        width = "48%",
        minHeight = 132,
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
            { x = 0, y = 12, blur = 18, spread = 0, color = { 5, 8, 16, 64 } },
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
                width = 44,
                height = 44,
                borderRadius = 16,
                backgroundColor = { accent[1], accent[2], accent[3], 20 },
                borderWidth = 1,
                borderColor = { accent[1], accent[2], accent[3], 60 },
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
    local currentLevel = progress.currentLevelIndex or 1
    local unlockedCount = progress.unlockedLevelCount or 1

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
                                text = "Level Select",
                                fontSize = ThemeTokens.typography.hero,
                                fontColor = ThemeTokens.colors.textPrimary,
                            },
                            UI.Label {
                                text = chapter.districtName or "South Bank Neon",
                                fontSize = ThemeTokens.typography.body,
                                fontColor = ThemeTokens.colors.textSecondary,
                            },
                        },
                    },
                    SoftButton {
                        text = "Back",
                        width = 88,
                        height = 44,
                        accent = "violet",
                        onClick = function()
                            if ctx.onBack then
                                ctx.onBack()
                            end
                        end,
                    },
                },
            },
            GlassCard {
                children = {
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        gap = 10,
                        children = {
                            StatChip {
                                label = "Playable levels",
                                value = tostring(unlockedCount),
                                valueColor = ThemeTokens.colors.mistCyan,
                                width = "31%",
                            },
                            StatChip {
                                label = "Current focus",
                                value = string.format("%02d", currentLevel),
                                valueColor = ThemeTokens.colors.coralFizz,
                                width = "31%",
                            },
                            StatChip {
                                label = "District tone",
                                value = "Warm mist",
                                valueColor = ThemeTokens.colors.mangoGlow,
                                width = "31%",
                            },
                        },
                    },
                },
            },
            GlassCard {
                flexGrow = 1,
                gap = 12,
                children = {
                    UI.Label {
                        text = "Tap a level card to enter the puzzle board.",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = ThemeTokens.colors.textSecondary,
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
