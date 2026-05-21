-- ============================================================================
-- 全息卡片 - 半透明深紫底 + 顶部青色光线
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")

--- 创建全息卡片
--- @param props table { children, width, height, padding, gap, ... }
local function HoloCard(props)
    props = props or {}
    local children = props.children or {}

    -- 顶部发光装饰线
    local topLine = UI.Panel {
        width = "100%",
        height = 1,
        backgroundGradient = {
            type = "linear",
            direction = "to-right",
            from = { 0, 255, 255, 0 },
            to = { 0, 255, 255, 120 },
        },
    }

    -- 左侧竖条
    local leftBar = UI.Panel {
        position = "absolute",
        left = 0,
        top = 0,
        bottom = 0,
        width = 2,
        backgroundGradient = {
            type = "linear",
            direction = "to-bottom",
            from = { 0, 255, 255, 100 },
            to = { 0, 255, 255, 0 },
        },
    }

    -- 合并子元素：顶部线 + 左边栏 + 内容
    local allChildren = { topLine, leftBar }
    for _, child in ipairs(children) do
        table.insert(allChildren, child)
    end

    return UI.Panel {
        width = props.width or "100%",
        height = props.height,
        padding = props.padding or Theme.spacing.lg,
        gap = props.gap or Theme.spacing.md,
        backgroundColor = Theme.colors.bgCard,
        borderRadius = Theme.radius.md,
        borderWidth = { 0, 0, 0, 0 },
        backdropBlur = 6,
        flexDirection = props.flexDirection or "column",
        justifyContent = props.justifyContent,
        alignItems = props.alignItems,
        flexWrap = props.flexWrap,
        children = allChildren,
    }
end

return HoloCard
