local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local ChapterSelectScreen = {}

local MASCOT_IMAGE = "assets/images/ui/cat-mascot-badge-v1.jpg"

local function BuildLockedCard(title, note, accent)
    return GlassCard {
        gap = 8,
        backgroundColor = { 255, 255, 255, 160 },
        borderColor = { accent[1], accent[2], accent[3], 48 },
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
                text = "敬请期待",
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
    local colors = ThemeTokens.colors
    local totalLevels = #(ctx.levels or {})
    local unlockedCount = totalLevels == 0 and 0 or math.max(1, math.min(progress.unlockedLevelCount or 1, totalLevels))

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
                                text = "乐园地图",
                                fontSize = ThemeTokens.typography.hero,
                                fontColor = colors.textPrimary,
                            },
                            UI.Label {
                                text = "挑一片猫咪乐园，把彩虹瓶子整理得漂漂亮亮。",
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
                                label = "当前乐园",
                                value = chapter.name or "第一章",
                                valueColor = colors.mistCyan,
                                width = "48%",
                                alignItems = "flex-start",
                            },
                            StatChip {
                                label = "已解锁关卡",
                                value = string.format("%d / %d", unlockedCount, totalLevels),
                                valueColor = colors.coralFizz,
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
                backgroundColor = { 255, 250, 246, 220 },
                borderColor = { 255, 255, 255, 122 },
                children = {
                    UI.Label {
                        text = chapter.districtName or "云朵猫镇",
                        fontSize = ThemeTokens.typography.caption,
                        fontColor = colors.textSecondary,
                    },
                    UI.Label {
                        text = chapter.tagline or "帮小猫把彩虹瓶子整理整齐。",
                        fontSize = ThemeTokens.typography.title,
                        fontColor = colors.textPrimary,
                    },
                    UI.Label {
                        text = "这里有奶油屋顶、猫耳气球和软绵绵的云朵坡道，是最适合开始倒水冒险的第一座乐园。",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = colors.textSecondary,
                    },
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        gap = 8,
                        children = {
                            StatChip {
                                label = "氛围",
                                value = "软萌明亮",
                                valueColor = colors.mangoGlow,
                                width = "31%",
                            },
                            StatChip {
                                label = "特色",
                                value = "猫咪气球",
                                valueColor = colors.jadeMint,
                                width = "31%",
                            },
                            StatChip {
                                label = "玩法",
                                value = "轻松倒水",
                                valueColor = colors.coralFizz,
                                width = "31%",
                            },
                        },
                    },
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        justifyContent = "space-between",
                        gap = 10,
                        children = {
                            SoftButton {
                                text = "返回首页",
                                width = 136,
                                height = 52,
                                accent = "violet",
                                onClick = function()
                                    if ctx.onBack then
                                        ctx.onBack()
                                    end
                                end,
                            },
                            SoftButton {
                                text = "进入关卡",
                                width = 150,
                                height = 52,
                                accent = "mint",
                                onClick = function()
                                    if ctx.onSelectChapter then
                                        ctx.onSelectChapter(chapter.id)
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
                backgroundColor = { 255, 251, 248, 205 },
                children = {
                    UI.Label {
                        text = "下一站乐园",
                        fontSize = ThemeTokens.typography.section,
                        fontColor = colors.textPrimary,
                    },
                    BuildLockedCard(
                        "曲奇海港",
                        "码头边会堆满饼干箱和鱼骨路标，更多多瓶组合和路线障碍会从这里开始。",
                        colors.cableViolet
                    ),
                    BuildLockedCard(
                        "星星游乐街",
                        "夜空下的游乐街满是旋转星灯和弹跳彩桥，适合加入更多趣味机关。",
                        colors.mangoGlow
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
