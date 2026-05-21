local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")

local function GlassCard(props)
    props = props or {}

    return UI.Panel {
        width = props.width or "100%",
        height = props.height,
        minHeight = props.minHeight,
        flexGrow = props.flexGrow,
        flexShrink = props.flexShrink,
        paddingLeft = props.paddingLeft or 18,
        paddingRight = props.paddingRight or 18,
        paddingTop = props.paddingTop or 18,
        paddingBottom = props.paddingBottom or 18,
        gap = props.gap or 14,
        backgroundColor = props.backgroundColor or ThemeTokens.colors.cardFog,
        borderRadius = props.borderRadius or ThemeTokens.radius.card,
        borderWidth = props.borderWidth or 1,
        borderColor = props.borderColor or ThemeTokens.colors.cardHighlight,
        flexDirection = props.flexDirection or "column",
        justifyContent = props.justifyContent,
        alignItems = props.alignItems,
        children = props.children or {},
        boxShadow = props.boxShadow or {
            { x = 0, y = 16, blur = 24, spread = 0, color = { 5, 8, 16, 80 } },
        },
    }
end

return GlassCard
