local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local ChapterSelectScreen = {}

local function BuildLockedCard(title, note, accent)
    return GlassCard {
        gap = 8,
        backgroundColor = { 255, 255, 255, 12 },
        borderColor = { accent[1], accent[2], accent[3], 34 },
        children = {
            UI.Label {
                text = title,
                fontSize = ThemeTokens.typography.section,
                fontColor = ThemeTokens.colors.textPrimary,
            },
            UI.Label {
                text = note,
                fontSize = ThemeTokens.typography.body,
                fontColor = ThemeTokens.colors.textSecondary,
            },
            UI.Label {
                text = "Locked future district",
                fontSize = ThemeTokens.typography.caption,
                fontColor = accent,
            },
        },
    }
end

function ChapterSelectScreen.Create(ctx)
    ctx = ctx or {}
    local chapter = ctx.chapter or {}
    local progress = ctx.progress or {}

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
                                text = "District Select",
                                fontSize = ThemeTokens.typography.hero,
                                fontColor = ThemeTokens.colors.textPrimary,
                            },
                            UI.Label {
                                text = "Choose the next slice of cyber Chongqing to restore.",
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
                                label = "Playable now",
                                value = chapter.name or "Chapter 01",
                                valueColor = ThemeTokens.colors.mistCyan,
                                width = "48%",
                                alignItems = "flex-start",
                            },
                            StatChip {
                                label = "Unlocked",
                                value = string.format("%d / %d", progress.unlockedLevelCount or 1, #(ctx.levels or {})),
                                valueColor = ThemeTokens.colors.coralFizz,
                                width = "48%",
                                alignItems = "flex-start",
                            },
                        },
                    },
                },
            },
            GlassCard {
                gap = 16,
                paddingTop = 20,
                paddingBottom = 20,
                borderColor = { 106, 236, 255, 58 },
                children = {
                    UI.Label {
                        text = chapter.districtName or "South Bank Neon",
                        fontSize = ThemeTokens.typography.caption,
                        fontColor = ThemeTokens.colors.textSecondary,
                    },
                    UI.Label {
                        text = chapter.tagline or "Bring the district lights back online.",
                        fontSize = ThemeTokens.typography.title,
                        fontColor = ThemeTokens.colors.textPrimary,
                    },
                    UI.Label {
                        text = "A hillside snack-market district with cable cars, bridge shadows, warm fog, and toy-like color energy flowing through every lane.",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = ThemeTokens.colors.textSecondary,
                    },
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        gap = 8,
                        children = {
                            StatChip {
                                label = "Mood",
                                value = "Soft neon",
                                valueColor = ThemeTokens.colors.mangoGlow,
                                width = "31%",
                            },
                            StatChip {
                                label = "Landmark",
                                value = "Cable line",
                                valueColor = ThemeTokens.colors.jadeMint,
                                width = "31%",
                            },
                            StatChip {
                                label = "Play style",
                                value = "Classic sort",
                                valueColor = ThemeTokens.colors.coralFizz,
                                width = "31%",
                            },
                        },
                    },
                    SoftButton {
                        text = "View Levels",
                        width = 160,
                        height = 54,
                        accent = "mint",
                        onClick = function()
                            if ctx.onSelectChapter then
                                ctx.onSelectChapter(chapter.id)
                            end
                        end,
                    },
                },
            },
            GlassCard {
                flexGrow = 1,
                gap = 12,
                children = {
                    UI.Label {
                        text = "Future districts",
                        fontSize = ThemeTokens.typography.section,
                        fontColor = ThemeTokens.colors.textPrimary,
                    },
                    BuildLockedCard(
                        "Cloud Rail Arcade",
                        "A playful ridge-top district with hanging tracks, arcade facades, and switchback mechanics.",
                        ThemeTokens.colors.cableViolet
                    ),
                    BuildLockedCard(
                        "River Port Glow",
                        "A lower riverfront district with ferry lights, mist, and contamination cleanup mechanics.",
                        ThemeTokens.colors.mangoGlow
                    ),
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

return ChapterSelectScreen
