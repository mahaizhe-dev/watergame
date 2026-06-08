local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")

local function StatChip(props)
    props = props or {}

    return UI.Panel {
        width = props.width,
        minWidth = props.minWidth or 88,
        paddingLeft = 14,
        paddingRight = 14,
        paddingTop = 10,
        paddingBottom = 10,
        gap = 2,
        backgroundColor = props.backgroundColor or { 255, 255, 255, 190 },
        borderRadius = ThemeTokens.radius.chip,
        borderWidth = 1,
        borderColor = props.borderColor or { 255, 255, 255, 150 },
        alignItems = props.alignItems or "center",
        children = {
            UI.Label {
                text = props.label or "标签",
                fontSize = ThemeTokens.typography.caption,
                fontColor = ThemeTokens.colors.textSecondary,
            },
            UI.Label {
                id = props.id,
                text = props.value or "0",
                fontSize = props.valueFontSize or ThemeTokens.typography.section,
                fontColor = props.valueColor or ThemeTokens.colors.textPrimary,
            },
        }
    }
end

return StatChip
