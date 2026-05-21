local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local HomeScreen = {}

local function BuildMoodTag(text, color)
    return UI.Panel {
        paddingLeft = 12,
        paddingRight = 12,
        paddingTop = 7,
        paddingBottom = 7,
        backgroundColor = { color[1], color[2], color[3], 26 },
        borderRadius = 999,
        borderWidth = 1,
        borderColor = { color[1], color[2], color[3], 84 },
        children = {
            UI.Label {
                text = text,
                fontSize = ThemeTokens.typography.caption,
                fontColor = color,
            },
        }
    }
end

function HomeScreen.Create(ctx)
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
        gap = 14,
        children = {
            DistrictBackdrop {},
            UI.Panel {
                width = "100%",
                gap = 8,
                children = {
                    UI.Label {
                        text = "Cyber Chongqing Pour",
                        fontSize = ThemeTokens.typography.hero,
                        fontColor = ThemeTokens.colors.textPrimary,
                    },
                    UI.Label {
                        text = "A portrait-first casual puzzle game with toy-like liquids and a soft neon mountain city.",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = ThemeTokens.colors.textSecondary,
                    },
                    UI.Panel {
                        flexDirection = "row",
                        flexWrap = "wrap",
                        gap = 8,
                        children = {
                            BuildMoodTag("Cute sci-fi", ThemeTokens.colors.mistCyan),
                            BuildMoodTag("Mobile portrait", ThemeTokens.colors.mangoGlow),
                            BuildMoodTag("Expandable rules", ThemeTokens.colors.jadeMint),
                        },
                    },
                },
            },
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                flexWrap = "wrap",
                gap = 10,
                children = {
                    StatChip {
                        label = "Current chapter",
                        value = chapter.name or "Chapter 01",
                        valueColor = ThemeTokens.colors.mistCyan,
                        width = "48%",
                        alignItems = "flex-start",
                    },
                    StatChip {
                        label = "Unlocked levels",
                        value = tostring(progress.unlockedLevelCount or 1),
                        valueColor = ThemeTokens.colors.coralFizz,
                        width = "48%",
                        alignItems = "flex-start",
                    },
                },
            },
            GlassCard {
                gap = 16,
                paddingTop = 20,
                paddingBottom = 20,
                children = {
                    UI.Panel {
                        width = "100%",
                        gap = 5,
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
                        },
                    },
                    UI.Label {
                        text = "The reboot starts with a soft-neon district, one-thumb puzzle flow, and a structure built for lots of mechanics and lots of levels.",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = ThemeTokens.colors.textSecondary,
                    },
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        justifyContent = "space-between",
                        gap = 10,
                        children = {
                            SoftButton {
                                text = "Continue",
                                width = 132,
                                height = 52,
                                accent = "mint",
                                onClick = function()
                                    if ctx.onContinue then
                                        ctx.onContinue()
                                    end
                                end,
                            },
                            SoftButton {
                                text = "Districts",
                                width = 132,
                                height = 52,
                                accent = "warm",
                                onClick = function()
                                    if ctx.onOpenChapters then
                                        ctx.onOpenChapters()
                                    end
                                end,
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
                        text = "Design pillars",
                        fontSize = ThemeTokens.typography.section,
                        fontColor = ThemeTokens.colors.textPrimary,
                    },
                    UI.Label {
                        text = "1. Fast portrait interactions.\n2. Rounded toy-like vessels.\n3. Soft cyber Chongqing atmosphere.\n4. Data-first level expansion.",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = ThemeTokens.colors.textSecondary,
                    },
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        gap = 10,
                        children = {
                            GlassCard {
                                width = "48%",
                                minHeight = 96,
                                paddingTop = 14,
                                paddingBottom = 14,
                                backgroundColor = { 255, 255, 255, 14 },
                                borderColor = { 106, 236, 255, 36 },
                                children = {
                                    UI.Label {
                                        text = "Session",
                                        fontSize = ThemeTokens.typography.caption,
                                        fontColor = ThemeTokens.colors.textSecondary,
                                    },
                                    UI.Label {
                                        text = "1-3 min",
                                        fontSize = ThemeTokens.typography.section,
                                        fontColor = ThemeTokens.colors.mistCyan,
                                    },
                                },
                            },
                            GlassCard {
                                width = "48%",
                                minHeight = 96,
                                paddingTop = 14,
                                paddingBottom = 14,
                                backgroundColor = { 255, 255, 255, 14 },
                                borderColor = { 255, 191, 84, 36 },
                                children = {
                                    UI.Label {
                                        text = "Theme",
                                        fontSize = ThemeTokens.typography.caption,
                                        fontColor = ThemeTokens.colors.textSecondary,
                                    },
                                    UI.Label {
                                        text = "Soft neon",
                                        fontSize = ThemeTokens.typography.section,
                                        fontColor = ThemeTokens.colors.mangoGlow,
                                    },
                                },
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
            if key == KEY_RETURN and ctx.onOpenChapters then
                ctx.onOpenChapters()
                return true
            end
            return false
        end,
    }
end

return HomeScreen
