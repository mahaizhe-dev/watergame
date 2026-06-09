local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local ChapterSelectScreen = {}

local MASCOT_IMAGE = "Textures/ui/cat-mascot-badge-v1.png"

local function clearedCount(progress, chapterIndex)
    if not progress or type(progress.clearedLevelsByChapter) ~= "table" then
        return 0
    end
    return tonumber(progress.clearedLevelsByChapter[chapterIndex]) or 0
end

local function unlockedChapterCount(progress)
    return tonumber(progress and progress.unlockedChapterCount) or 0
end

local function BuildChapterCard(chapterIndex, chapter, progress, onSelect)
    chapter = chapter or {}
    local colors = ThemeTokens.colors
    local unlocked = chapterIndex <= unlockedChapterCount(progress)
    local cleared = clearedCount(progress, chapterIndex)
    local totalLevels = #(chapter.levels or {})
    local accent = unlocked and colors.mistCyan or colors.textMuted

    return UI.Panel {
        width = "48%",
        minHeight = 166,
        paddingLeft = 14,
        paddingRight = 14,
        paddingTop = 14,
        paddingBottom = 14,
        gap = 8,
        backgroundColor = unlocked and { 255, 250, 246, 224 } or { 255, 255, 255, 142 },
        borderRadius = ThemeTokens.radius.card,
        borderWidth = 1,
        borderColor = unlocked and { 255, 255, 255, 138 } or { 255, 255, 255, 96 },
        boxShadow = unlocked and {
            { x = 0, y = 12, blur = 18, spread = 0, color = { 152, 114, 100, 34 } },
        } or nil,
        pointerEvents = unlocked and "auto" or "none",
        onPointerDown = function(event, widget)
            if unlocked then
                widget.scale = 0.97
            end
        end,
        onPointerUp = function(event, widget)
            widget.scale = 1.0
            if unlocked and onSelect then
                onSelect(chapterIndex)
            end
        end,
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                children = {
                    UI.Label {
                        text = string.format("第 %02d 章", chapterIndex),
                        fontSize = ThemeTokens.typography.caption,
                        fontColor = colors.textSecondary,
                    },
                    UI.Label {
                        text = unlocked and string.format("%d/20", cleared) or "未解锁",
                        fontSize = ThemeTokens.typography.caption,
                        fontColor = accent,
                    },
                },
            },
            UI.Label {
                text = chapter.name or "未命名章节",
                fontSize = ThemeTokens.typography.section,
                fontColor = unlocked and colors.textPrimary or colors.textMuted,
            },
            UI.Label {
                text = chapter.districtName or "猫咪城区",
                fontSize = ThemeTokens.typography.caption,
                fontColor = colors.textSecondary,
            },
            UI.Label {
                text = chapter.mechanicFocus or "经典倒水",
                fontSize = ThemeTokens.typography.body,
                fontColor = accent,
            },
            UI.Label {
                text = unlocked
                    and string.format("本章共 %d 关，主打 %s。", totalLevels, chapter.mechanicFocus or "经典规则")
                    or "先完成前面的乐园，猫咪才会带你过来。",
                fontSize = ThemeTokens.typography.caption,
                fontColor = unlocked and colors.textSecondary or colors.textMuted,
            },
        },
    }
end

function ChapterSelectScreen.Create(ctx)
    ctx = ctx or {}
    local chapters = ctx.chapters or {}
    local progress = ctx.progress or {}
    local colors = ThemeTokens.colors
    local totalCleared = tonumber(ctx.totalCleared) or 0
    local totalLevels = tonumber(ctx.totalLevels) or 0

    local chapterCards = {}
    for chapterIndex, chapter in ipairs(chapters) do
        table.insert(chapterCards, BuildChapterCard(chapterIndex, chapter, progress, function(selectedChapterIndex)
            if ctx.onSelectChapter then
                ctx.onSelectChapter(selectedChapterIndex)
            end
        end))
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
                                text = "乐园地图",
                                fontSize = ThemeTokens.typography.hero,
                                fontColor = colors.textPrimary,
                            },
                            UI.Label {
                                text = "8 座猫咪乐园全部已经排进来了，挑一章继续整理彩虹瓶。",
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
                                label = "已解锁章节",
                                value = string.format("%d / %d", unlockedChapterCount(progress), #chapters),
                                valueColor = colors.mistCyan,
                                width = "48%",
                                alignItems = "flex-start",
                            },
                            StatChip {
                                label = "总进度",
                                value = string.format("%d / %d", totalCleared, totalLevels),
                                valueColor = colors.coralFizz,
                                width = "48%",
                                alignItems = "flex-start",
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
                        text = "每章 20 关，最后两章会把盘面扩到 12 个瓶子。",
                        fontSize = ThemeTokens.typography.body,
                        fontColor = colors.textSecondary,
                    },
                },
            },
            GlassCard {
                flexGrow = 1,
                gap = 12,
                backgroundColor = { 255, 251, 248, 205 },
                children = {
                    UI.Panel {
                        width = "100%",
                        flexDirection = "row",
                        flexWrap = "wrap",
                        justifyContent = "space-between",
                        gap = 10,
                        children = chapterCards,
                    },
                },
            },
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "flex-end",
                children = {
                    SoftButton {
                        text = "返回首页",
                        width = 148,
                        height = 52,
                        accent = "violet",
                        onClick = function()
                            if ctx.onBack then
                                ctx.onBack()
                            end
                        end,
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

return ChapterSelectScreen
