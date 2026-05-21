-- ============================================================================
-- 数据面板 - 标签+数值 显示组件
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")

--- 创建数据面板
--- @param props table { label, value, valueColor, width }
local function DataPanel(props)
    props = props or {}
    return UI.Panel {
        width = props.width,
        alignItems = props.alignItems or "center",
        gap = 2,
        children = {
            UI.Label {
                text = props.label or "Label",
                fontSize = Theme.fontSize.xs,
                fontColor = Theme.colors.textSecondary,
            },
            UI.Label {
                id = props.id,
                text = props.value or "0",
                fontSize = props.valueFontSize or Theme.fontSize.lg,
                fontColor = props.valueColor or Theme.colors.neonCyan,
                transition = "fontColor 0.3s easeOut",
            },
        }
    }
end

return DataPanel
