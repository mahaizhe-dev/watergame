local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")

local function getAccentColors(accent)
    local colors = ThemeTokens.colors

    if accent == "warm" then
        return colors.mangoGlow, colors.coralFizz
    end
    if accent == "mint" then
        return colors.jadeMint, colors.aquaPop
    end
    if accent == "violet" then
        return colors.cableViolet, colors.coralFizz
    end
    return colors.mistCyan, colors.aquaPop
end

local function SoftButton(props)
    props = props or {}

    local primary, secondary = getAccentColors(props.accent)

    return UI.Button {
        text = props.text or "Button",
        width = props.width or 132,
        height = props.height or 52,
        fontSize = props.fontSize or ThemeTokens.typography.body,
        fontColor = ThemeTokens.colors.textPrimary,
        backgroundColor = props.backgroundColor or { 38, 47, 74, 232 },
        borderWidth = 1.5,
        borderColor = primary,
        borderRadius = props.borderRadius or ThemeTokens.radius.button,
        boxShadow = {
            { x = 0, y = 10, blur = 20, spread = 0, color = { 5, 8, 16, 90 } },
            { x = 0, y = 0, blur = 16, spread = 0, color = { primary[1], primary[2], primary[3], 36 } },
        },
        transition = ThemeTokens.motion.fast,
        onPointerEnter = function(event, widget)
            widget.scale = 1.02
            widget.borderColor = secondary
        end,
        onPointerLeave = function(event, widget)
            widget.scale = 1.0
            widget.borderColor = primary
        end,
        onPointerDown = function(event, widget)
            widget.scale = 0.96
        end,
        onPointerUp = function(event, widget)
            widget.scale = 1.02
        end,
        onClick = props.onClick,
    }
end

return SoftButton
