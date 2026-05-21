-- ============================================================================
-- 霓虹按钮 - 发光描边 + 点击缩放
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")

--- 创建霓虹按钮
--- @param props table { text, width, height, color("cyan"|"pink"), fontSize, onClick }
local function NeonButton(props)
    props = props or {}
    local color = props.color or "cyan"
    local isCyan = (color == "cyan")

    local borderClr = isCyan and Theme.colors.neonCyan or Theme.colors.neonPink
    local glowShadow = isCyan and Theme.glow.cyan or Theme.glow.pink
    local glowStrong = isCyan and Theme.glow.cyanStrong or Theme.glow.pinkStrong

    return UI.Button {
        text = props.text or "Button",
        width = props.width or 180,
        height = props.height or 46,
        fontSize = props.fontSize or Theme.fontSize.base,
        fontColor = borderClr,
        backgroundColor = { 10, 10, 20, 220 },
        borderWidth = 1.5,
        borderColor = borderClr,
        borderRadius = Theme.radius.sm,
        boxShadow = glowShadow,
        transition = Theme.transition.fast,
        onPointerEnter = function(event, widget)
            widget.boxShadow = glowStrong
            widget.scale = 1.03
        end,
        onPointerLeave = function(event, widget)
            widget.boxShadow = glowShadow
            widget.scale = 1.0
        end,
        onPointerDown = function(event, widget)
            widget.scale = 0.95
        end,
        onPointerUp = function(event, widget)
            widget.scale = 1.03
        end,
        onClick = props.onClick,
    }
end

return NeonButton
