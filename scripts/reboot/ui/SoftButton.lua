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

local function getTextColor(accent, fallback)
    if fallback then
        return fallback
    end

    if accent == "warm" or accent == "mint" then
        return { 87, 57, 68, 255 }
    end

    return { 255, 255, 255, 255 }
end

local function SoftButton(props)
    props = props or {}

    local primary, secondary = getAccentColors(props.accent)
    local backgroundColor = props.backgroundColor or { primary[1], primary[2], primary[3], 236 }
    local hoverColor = { secondary[1], secondary[2], secondary[3], 244 }

    return UI.Button {
        text = props.text or "按钮",
        width = props.width or 132,
        height = props.height or 52,
        fontSize = props.fontSize or ThemeTokens.typography.body,
        fontWeight = "bold",
        fontColor = getTextColor(props.accent, props.fontColor),
        backgroundColor = backgroundColor,
        borderWidth = 0,
        borderRadius = props.borderRadius or ThemeTokens.radius.button,
        boxShadow = {
            { x = 0, y = 7, blur = 18, spread = 0, color = { primary[1], primary[2], primary[3], 92 } },
            { x = 0, y = 2, blur = 5, spread = 0, color = { 55, 34, 42, 26 } },
        },
        transition = ThemeTokens.motion.fast,
        onPointerEnter = function(event, widget)
            widget.scale = 1.04
            widget.backgroundColor = hoverColor
        end,
        onPointerLeave = function(event, widget)
            widget.scale = 1.0
            widget.backgroundColor = backgroundColor
        end,
        onPointerDown = function(event, widget)
            widget.scale = 0.95
        end,
        onPointerUp = function(event, widget)
            widget.scale = 1.04
        end,
        onClick = props.onClick,
    }
end

return SoftButton
