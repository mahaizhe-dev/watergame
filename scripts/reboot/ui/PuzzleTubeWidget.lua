local UI = require("urhox-libs/UI")

local PuzzleTubeWidget = UI.Widget:Extend("PuzzleTubeWidget")

function PuzzleTubeWidget:Init(props)
    props = props or {}
    props.width = props.width or 86
    props.height = props.height or 188
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
    if not tube then
        return
    end

    local isSelected = self.getSelectedIndex_ and self.getSelectedIndex_() == self.tubeIndex_
    local shiftY = isSelected and -12 or 0
    local shadowAlpha = self.hovered_ and 55 or 35

    local outerX = layout.x + 16
    local outerY = layout.y + 14 + shiftY
    local outerW = layout.w - 32
    local outerH = layout.h - 34

    local innerX = outerX + 6
    local innerY = outerY + 12
    local innerW = outerW - 12
    local innerH = outerH - 22
    local layerH = innerH / self.capacity_

    nvgBeginPath(nvg)
    nvgEllipse(nvg, layout.x + layout.w * 0.5, layout.y + layout.h - 12 + shiftY, outerW * 0.64, 10)
    local baseShadow = nvgRadialGradient(
        nvg,
        layout.x + layout.w * 0.5,
        layout.y + layout.h - 12 + shiftY,
        0,
        outerW * 0.7,
        nvgRGBA(10, 12, 20, shadowAlpha),
        nvgRGBA(10, 12, 20, 0)
    )
    nvgFillPaint(nvg, baseShadow)
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, outerX, outerY, outerW, outerH, 26)
    nvgFillColor(nvg, nvgRGBA(236, 244, 255, 18))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, outerX, outerY, outerW, outerH, 26)
    if isSelected then
        nvgStrokeColor(nvg, nvgRGBA(106, 236, 255, 220))
        nvgStrokeWidth(nvg, 2.2)
    else
        nvgStrokeColor(nvg, nvgRGBA(238, 245, 255, 82))
        nvgStrokeWidth(nvg, 1.5)
    end
    nvgStroke(nvg)

    if isSelected then
        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, outerX - 3, outerY - 3, outerW + 6, outerH + 6, 28)
        nvgStrokeColor(nvg, nvgRGBA(106, 236, 255, 60))
        nvgStrokeWidth(nvg, 6)
        nvgStroke(nvg)
    end

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, innerX, innerY, innerW, innerH, 20)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 10))
    nvgFill(nvg)

    nvgSave(nvg)
    nvgScissor(nvg, innerX, innerY, innerW, innerH)

    for layerIndex = 1, #tube do
        local color = self.palette_[tube[layerIndex]] or { 255, 255, 255, 255 }
        local top = innerY + innerH - layerIndex * layerH
        local height = layerH + 1

        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, innerX + 2, top, innerW - 4, height + 4, 12)
        local fill = nvgLinearGradient(
            nvg,
            innerX,
            top,
            innerX,
            top + height,
            nvgRGBA(
                math.min(color[1] + 18, 255),
                math.min(color[2] + 18, 255),
                math.min(color[3] + 18, 255),
                240
            ),
            nvgRGBA(
                math.max(color[1] - 18, 0),
                math.max(color[2] - 18, 0),
                math.max(color[3] - 18, 0),
                250
            )
        )
        nvgFillPaint(nvg, fill)
        nvgFill(nvg)

        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, innerX + 6, top + 5, math.max(innerW * 0.18, 8), math.max(height - 10, 6), 6)
        nvgFillColor(nvg, nvgRGBA(255, 255, 255, 34))
        nvgFill(nvg)
    end

    nvgRestore(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, outerX + 9, outerY + 12, 7, outerH - 30, 4)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 28))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, outerX + outerW * 0.5 - 12, outerY - 6, 24, 10, 5)
    nvgFillColor(nvg, nvgRGBA(245, 248, 255, 90))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgCircle(nvg, layout.x + layout.w * 0.5, layout.y + layout.h - 14 + shiftY, 14)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 24))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgCircle(nvg, layout.x + layout.w * 0.5, layout.y + layout.h - 14 + shiftY, 14)
    nvgStrokeColor(nvg, nvgRGBA(255, 255, 255, 44))
    nvgStrokeWidth(nvg, 1)
    nvgStroke(nvg)
end

return PuzzleTubeWidget
