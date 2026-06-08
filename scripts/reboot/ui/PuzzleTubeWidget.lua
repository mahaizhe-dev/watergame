local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")

local PuzzleTubeWidget = UI.Widget:Extend("PuzzleTubeWidget")

function PuzzleTubeWidget:Init(props)
    props = props or {}
    props.width = props.width or 94
    props.height = props.height or 196
    props.pointerEvents = "auto"
    UI.Widget.Init(self, props)

    self.tubeIndex_ = props.tubeIndex or 1
    self.capacity_ = props.capacity or 4
    self.getTube_ = props.getTube
    self.getSelectedIndex_ = props.getSelectedIndex
    self.onTap_ = props.onTap
    self.palette_ = props.palette or {}
    self.hovered_ = false
end

function PuzzleTubeWidget:OnClick(event)
    if self.onTap_ then
        self.onTap_(self.tubeIndex_)
    end
end

function PuzzleTubeWidget:OnPointerEnter(event)
    self.hovered_ = true
end

function PuzzleTubeWidget:OnPointerLeave(event)
    self.hovered_ = false
end

function PuzzleTubeWidget:Render(nvg)
    local layout = self:GetAbsoluteLayout()
    if not layout then
        return
    end

    local tube = self.getTube_ and self.getTube_(self.tubeIndex_) or nil
    if type(tube) ~= "table" then
        return
    end

    local colors = ThemeTokens.colors
    local isSelected = self.getSelectedIndex_ and self.getSelectedIndex_() == self.tubeIndex_
    local shiftY = isSelected and -9 or 0
    local bodyX = layout.x + 23
    local bodyY = layout.y + 34 + shiftY
    local bodyW = layout.w - 46
    local bodyH = layout.h - 64
    local neckW = bodyW * 0.42
    local neckX = bodyX + (bodyW - neckW) * 0.5
    local neckH = 20
    local capW = bodyW * 0.64
    local capX = bodyX + (bodyW - capW) * 0.5
    local capH = 14
    local innerX = bodyX + 7
    local innerY = bodyY + 14
    local innerW = bodyW - 14
    local innerH = bodyH - 22
    local layerH = innerH / self.capacity_
    local shadowAlpha = self.hovered_ and 52 or 34

    nvgBeginPath(nvg)
    nvgEllipse(nvg, layout.x + layout.w * 0.5, layout.y + layout.h - 12 + shiftY, bodyW * 0.62, 8)
    local shadow = nvgRadialGradient(
        nvg,
        layout.x + layout.w * 0.5,
        layout.y + layout.h - 12 + shiftY,
        0,
        bodyW * 0.74,
        nvgRGBA(colors.shadowMauve[1], colors.shadowMauve[2], colors.shadowMauve[3], shadowAlpha),
        nvgRGBA(colors.shadowMauve[1], colors.shadowMauve[2], colors.shadowMauve[3], 0)
    )
    nvgFillPaint(nvg, shadow)
    nvgFill(nvg)

    if isSelected then
        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, bodyX - 4, bodyY - 4, bodyW + 8, bodyH + 8, 26)
        nvgStrokeColor(nvg, nvgRGBA(colors.mangoGlow[1], colors.mangoGlow[2], colors.mangoGlow[3], 90))
        nvgStrokeWidth(nvg, 6)
        nvgStroke(nvg)
    end

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, capX, bodyY - capH + 4, capW, capH, 8)
    nvgFillColor(nvg, nvgRGBA(255, 240, 222, 230))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, neckX, bodyY - 4, neckW, neckH, 11)
    nvgFillColor(nvg, nvgRGBA(255, 246, 236, 216))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX, bodyY + 12, bodyW, bodyH, 24)
    local bodyFill = nvgLinearGradient(
        nvg,
        bodyX,
        bodyY + 12,
        bodyX,
        bodyY + bodyH + 12,
        nvgRGBA(255, 253, 251, 224),
        nvgRGBA(241, 247, 251, 198)
    )
    nvgFillPaint(nvg, bodyFill)
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX, bodyY + 12, bodyW, bodyH, 24)
    if isSelected then
        nvgStrokeColor(nvg, nvgRGBA(colors.coralFizz[1], colors.coralFizz[2], colors.coralFizz[3], 228))
        nvgStrokeWidth(nvg, 2.2)
    else
        nvgStrokeColor(nvg, nvgRGBA(255, 255, 255, 170))
        nvgStrokeWidth(nvg, 1.5)
    end
    nvgStroke(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX + 6, bodyY + 22, bodyW - 12, 10, 5)
    nvgFillColor(nvg, nvgRGBA(colors.mangoGlow[1], colors.mangoGlow[2], colors.mangoGlow[3], 108))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, innerX, innerY + 14, innerW, innerH, 18)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 42))
    nvgFill(nvg)

    nvgSave(nvg)
    nvgScissor(nvg, innerX, innerY + 14, innerW, innerH)
    for layerIndex = 1, #tube do
        local color = self.palette_[tube[layerIndex]] or { 255, 255, 255, 255 }
        local top = innerY + 14 + innerH - layerIndex * layerH
        local height = layerH + 2

        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, innerX + 2, top, innerW - 4, height + 4, 10)
        local fill = nvgLinearGradient(
            nvg,
            innerX,
            top,
            innerX,
            top + height,
            nvgRGBA(
                math.min(color[1] + 20, 255),
                math.min(color[2] + 20, 255),
                math.min(color[3] + 20, 255),
                244
            ),
            nvgRGBA(
                math.max(color[1] - 10, 0),
                math.max(color[2] - 10, 0),
                math.max(color[3] - 10, 0),
                248
            )
        )
        nvgFillPaint(nvg, fill)
        nvgFill(nvg)

        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, innerX + 7, top + 5, math.max(innerW * 0.16, 8), math.max(height - 10, 6), 6)
        nvgFillColor(nvg, nvgRGBA(255, 255, 255, 44))
        nvgFill(nvg)
    end
    nvgRestore(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX + 10, bodyY + 26, 7, bodyH - 18, 4)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 48))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX + bodyW * 0.55, bodyY + 28, 6, bodyH * 0.36, 3)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 26))
    nvgFill(nvg)
end

return PuzzleTubeWidget
