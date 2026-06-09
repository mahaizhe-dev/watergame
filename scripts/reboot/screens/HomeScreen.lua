local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local HomeScreen = {}

local HERO_IMAGE = "assets/images/ui/cat-home-hero-v1.jpg"
local MASCOT_IMAGE = "assets/images/ui/cat-mascot-badge-v1.jpg"

local function BuildMoodTag(text, color)
    return UI.Panel {
        paddingLeft = 12,
        paddingRight = 12,
        paddingTop = 7,
        paddingBottom = 7,
        backgroundColor = { color[1], color[2], color[3], 34 },
        borderRadius = 999,
        borderWidth = 1,
        borderColor = { color[1], color[2], color[3], 72 },
        children = {
            UI.Label {
                text = text,
                fontSize = ThemeTokens.typography.caption,
                fontColor = ThemeTokens.colors.textPrimary,
            },
        },
    }
end

function HomeScreen.Create(ctx)
    ctx = ctx or {}
    local chapter = ctx.chapter or {}
    local progress = ctx.progress or {}
    local colors = ThemeTokens.colors
    local totalLevels = tonumber(ctx.totalLevels) or 0
    local totalCleared = tonumber(ctx.totalCleared) or 0
    local chapterIndex = tonumber(progress.currentChapterIndex) or 0
    local currentLevel = tonumber(progress.currentLevelIndex) or 0
    local unlockedCount = progress.unlockedLevelsByChapter
        and progress.unlockedLevelsByChapter[chapterIndex]
        or 0
    local hasPlayableLevel = chapterIndex > 0 and currentLevel > 0 and unlockedCount > 0
    local currentLevelText = currentLevel == 0 and "--" or string.format("%02d", currentLevel)
    local currentChapterText = chapterIndex == 0 and "--" or string.format("%02d", chapterIndex)
    local currentContinueLabel = ctx.currentContinueLabel
        or (hasPlayableLevel and string.format("继续第 %s 章", currentChapterText) or "查看章节")

    local root = UI.Panel {
        width = "100%",
        height = "100%",
        justifyContent = "flex-end",
        backgroundColor = colors.creamGlow,
        children = {
            UI.Panel {
                position = "absolute",
                top = 0, left = 0, right = 0, bottom = 0,
                backgroundImage = HERO_IMAGE,
                backgroundFit = "cover",
                backgroundPosition = "center top",
            },
            UI.Panel {
                position = "absolute",
                top = 0, left = 0, right = 0, bottom = 0,
                pointerEvents = "none",
                children = {
                    UI.Panel {
                        width = "100%",
                        flexGrow = 7,
                        backgroundGradient = {
                            type = "linear",
                            direction = "to-bottom",
                            from = { 255, 255, 255, 12 },
                            to = { 255, 255, 255, 0 },
                        },
                    },
                    UI.Panel {
                        width = "100%",
                        flexGrow = 7,
                        backgroundGradient = {
                            type = "linear",
                            direction = "to-bottom",
                            from = { 255, 252, 249, 0 },
                            to = { 255, 245, 237, 235 },
                        },
                    },
                    UI.Panel {
                        width = "100%",
                        flexGrow = 5,
                        backgroundColor = { 255, 245, 237, 235 },
                    },
                },
            },
            UI.Panel {
                position = "absolute",
                top = 22,
                right = 14,
                width = 92,
                height = 92,
                backgroundImage = MASCOT_IMAGE,
                backgroundFit = "contain",
            },
            UI.Panel {
                position = "absolute",
                top = 28,
                left = 14,
                gap = 8,
                children = {
                    BuildMoodTag("8章160关", colors.coralFizz),
                    UI.Panel {
                        paddingLeft = 14,
                        paddingRight = 14,
                        paddingTop = 10,
                        paddingBottom = 10,
                        backgroundColor = { 255, 251, 247, 210 },
                        borderRadius = 20,
                        borderWidth = 1,
                        borderColor = { 255, 255, 255, 132 },
                        children = {
                            UI.Label {
                                text = "猫咪倒水屋",
                                fontSize = ThemeTokens.typography.hero,
                                fontColor = colors.textPrimary,
                            },
                        },
                    },
                },
            },
            UI.Panel {
                width = "100%",
                paddingLeft = 14,
                paddingRight = 14,
                paddingTop = 18,
                paddingBottom = 16,
                gap = 12,
                children = {
                    GlassCard {
                        gap = 12,
                        backgroundColor = { 255, 250, 246, 226 },
                        borderColor = { 255, 255, 255, 136 },
                        children = {
                            UI.Panel {
                                width = "100%",
                                flexDirection = "row",
                                justifyContent = "space-between",
                                alignItems = "center",
                                children = {
                                    UI.Panel {
                                        gap = 6,
                                        width = "70%",
                                        children = {
                                            UI.Label {
                                                text = "跟着软乎乎的小店长，把 8 座猫咪乐园全部整理亮灯。",
                                                fontSize = ThemeTokens.typography.title,
                                                fontColor = colors.textPrimary,
                                            },
                                            UI.Label {
                                                text = chapter.tagline or "帮小猫把彩虹瓶子整理整齐。",
                                                fontSize = ThemeTokens.typography.body,
                                                fontColor = colors.textSecondary,
                                            },
                                        },
                                    },
                                    UI.Panel {
                                        width = 76,
                                        height = 76,
                                        backgroundImage = MASCOT_IMAGE,
                                        backgroundFit = "contain",
                                    },
                                },
                            },
                            UI.Panel {
                                flexDirection = "row",
                                flexWrap = "wrap",
                                gap = 8,
                                children = {
                                    BuildMoodTag("萌猫主题", colors.coralFizz),
                                    BuildMoodTag("章节战役", colors.mangoGlow),
                                    BuildMoodTag("12瓶终章", colors.jadeMint),
                                },
                            },
                            UI.Panel {
                                width = "100%",
                                flexDirection = "row",
                                flexWrap = "wrap",
                                gap = 10,
                                children = {
                                    StatChip {
                                        label = "当前章节",
                                        value = chapterIndex == 0 and "--" or string.format("%s章", currentChapterText),
                                        valueColor = colors.mistCyan,
                                        width = "31%",
                                    },
                                    StatChip {
                                        label = "继续关卡",
                                        value = currentLevelText,
                                        valueColor = colors.coralFizz,
                                        width = "31%",
                                    },
                                    StatChip {
                                        label = "已通关",
                                        value = string.format("%d/%d", totalCleared, totalLevels),
                                        valueColor = colors.mangoGlow,
                                        width = "31%",
                                    },
                                },
                            },
                            SoftButton {
                                text = currentContinueLabel,
                                width = "100%",
                                height = 62,
                                fontSize = ThemeTokens.typography.section,
                                accent = "mint",
                                onClick = function()
                                    if hasPlayableLevel and ctx.onContinue then
                                        ctx.onContinue()
                                    elseif ctx.onOpenChapters then
                                        ctx.onOpenChapters()
                                    end
                                end,
                            },
                            UI.Panel {
                                width = "100%",
                                flexDirection = "row",
                                justifyContent = "space-between",
                                gap = 10,
                                children = {
                                    SoftButton {
                                        text = "选择章节",
                                        width = 148,
                                        height = 54,
                                        accent = "warm",
                                        onClick = function()
                                            if ctx.onOpenChapters then
                                                ctx.onOpenChapters()
                                            end
                                        end,
                                    },
                                    SoftButton {
                                        text = "继续整理",
                                        width = 148,
                                        height = 54,
                                        accent = "violet",
                                        onClick = function()
                                            if ctx.onContinue then
                                                ctx.onContinue()
                                            end
                                        end,
                                    },
                                },
                            },
                        },
                    },
                    GlassCard {
                        gap = 8,
                        backgroundColor = { 255, 252, 249, 212 },
                        borderColor = { 255, 255, 255, 118 },
                        children = {
                            UI.Label {
                                text = chapter.mechanicFocus
                                    and string.format("当前章节主打：%s。先点起始瓶，再点目标瓶，相同颜色才能叠放。", chapter.mechanicFocus)
                                    or "先点起始瓶，再点目标瓶，相同颜色才能叠放。",
                                fontSize = ThemeTokens.typography.body,
                                fontColor = colors.textSecondary,
                            },
                        },
                    },
                },
            },
        },
    }

    return {
        root = root,
        HandleKey = function(key)
            if key == KEY_RETURN and ctx.onContinue then
                ctx.onContinue()
                return true
            end
            return false
        end,
    }
end

return HomeScreen
