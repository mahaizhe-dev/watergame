-- ============================================================================
-- 关卡选择页 - 网格布局 + 霓虹风格关卡卡片
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")
local HoloCard = require("ui.HoloCard")

local LevelPage = {}

-- 关卡数据模拟（实际从游戏数据中读取）
local TOTAL_LEVELS = 12
local UNLOCKED = 6
local STARS = { 3, 3, 2, 2, 1, 0 }  -- 已解锁关卡的星星数

--- 创建单个关卡卡片
local function LevelCard(index, unlocked, stars)
    local isPlayable = (index == UNLOCKED and stars == 0) or (index <= UNLOCKED)
    local isCurrent = (index == UNLOCKED and (stars == 0))

    -- 星星显示
    local starText = ""
    if unlocked and stars then
        for i = 1, 3 do
            starText = starText .. (i <= stars and "★" or "☆")
        end
    end

    local borderClr = { 40, 40, 60, 255 }
    local bgClr = { 20, 18, 30, 255 }
    local numColor = Theme.colors.textMuted
    local shadowSet = nil

    if unlocked then
        borderClr = { 60, 70, 100, 200 }
        bgClr = Theme.colors.bgCard
        numColor = Theme.colors.textPrimary
    end
    if isCurrent then
        borderClr = Theme.colors.neonCyan
        shadowSet = Theme.glow.cyan
        numColor = Theme.colors.neonCyan
    end

    local children = {}

    if unlocked then
        -- 关卡号
        table.insert(children, UI.Label {
            text = tostring(index),
            fontSize = Theme.fontSize.xl,
            fontColor = numColor,
        })
        -- 星星
        if stars and stars > 0 then
            table.insert(children, UI.Label {
                text = starText,
                fontSize = Theme.fontSize.xs,
                fontColor = Theme.colors.warning,
            })
        end
    else
        -- 锁定图标
        table.insert(children, UI.Label {
            text = "🔒",
            fontSize = Theme.fontSize.lg,
        })
        table.insert(children, UI.Label {
            text = tostring(index),
            fontSize = Theme.fontSize.sm,
            fontColor = Theme.colors.textMuted,
        })
    end

    return UI.Panel {
        width = 72,
        height = 80,
        borderRadius = Theme.radius.md,
        backgroundColor = bgClr,
        borderWidth = isCurrent and 1.5 or 1,
        borderColor = borderClr,
        boxShadow = shadowSet,
        justifyContent = "center",
        alignItems = "center",
        gap = 4,
        pointerEvents = unlocked and "auto" or "none",
        transition = Theme.transition.fast,
        onPointerDown = function(event, widget)
            if unlocked then
                widget.scale = 0.92
            end
        end,
        onPointerUp = function(event, widget)
            widget.scale = 1.0
        end,
        children = children,
    }
end

--- 创建关卡选择页内容
--- @param ctx table { onSelectLevel }
function LevelPage.Create(ctx)
    ctx = ctx or {}

    -- 页面标题
    local header = UI.Panel {
        width = "100%",
        paddingTop = Theme.spacing.lg,
        paddingBottom = Theme.spacing.sm,
        alignItems = "center",
        children = {
            UI.Label {
                text = "选择关卡",
                fontSize = Theme.fontSize.xl,
                fontColor = Theme.colors.textPrimary,
            },
            UI.Label {
                text = "已解锁 " .. UNLOCKED .. "/" .. TOTAL_LEVELS,
                fontSize = Theme.fontSize.sm,
                fontColor = Theme.colors.textSecondary,
                marginTop = Theme.spacing.xs,
            },
        }
    }

    -- 关卡网格
    local gridChildren = {}
    for i = 1, TOTAL_LEVELS do
        local unlocked = (i <= UNLOCKED)
        local stars = unlocked and (STARS[i] or 0) or nil
        table.insert(gridChildren, LevelCard(i, unlocked, stars))
    end

    local grid = UI.Panel {
        width = "100%",
        flexDirection = "row",
        flexWrap = "wrap",
        justifyContent = "center",
        gap = Theme.spacing.md,
        paddingLeft = Theme.spacing.lg,
        paddingRight = Theme.spacing.lg,
        paddingTop = Theme.spacing.md,
        children = gridChildren,
    }

    -- 章节信息卡片
    local chapterCard = HoloCard {
        padding = Theme.spacing.md,
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                alignItems = "center",
                gap = Theme.spacing.md,
                children = {
                    UI.Panel {
                        width = 40,
                        height = 40,
                        borderRadius = Theme.radius.sm,
                        backgroundColor = { 0, 255, 255, 20 },
                        borderWidth = 1,
                        borderColor = { 0, 255, 255, 60 },
                        justifyContent = "center",
                        alignItems = "center",
                        children = {
                            UI.Label {
                                text = "I",
                                fontSize = Theme.fontSize.lg,
                                fontColor = Theme.colors.neonCyan,
                            },
                        }
                    },
                    UI.Panel {
                        flexGrow = 1,
                        flexShrink = 1,
                        gap = 2,
                        children = {
                            UI.Label {
                                text = "第一章：解放碑",
                                fontSize = Theme.fontSize.base,
                                fontColor = Theme.colors.textPrimary,
                            },
                            UI.Label {
                                text = "霓虹初现，探索赛博重庆的起点",
                                fontSize = Theme.fontSize.xs,
                                fontColor = Theme.colors.textSecondary,
                            },
                        }
                    },
                }
            },
        }
    }

    return UI.Panel {
        width = "100%",
        flexGrow = 1,
        gap = Theme.spacing.md,
        paddingLeft = Theme.spacing.md,
        paddingRight = Theme.spacing.md,
        paddingBottom = Theme.spacing.md,
        children = {
            header,
            chapterCard,
            grid,
        }
    }
end

return LevelPage
