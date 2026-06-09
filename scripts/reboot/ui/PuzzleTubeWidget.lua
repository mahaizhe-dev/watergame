local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")

local PuzzleTubeWidget = UI.Widget:Extend("PuzzleTubeWidget")

local function getBodyHalfWidth(maxHalfWidth, t)
    if t < 0.14 then
        local p = t / 0.14
        return maxHalfWidth * (0.58 + 0.42 * math.sqrt(p))
    end

    if t < 0.74 then
        local offset = math.abs(t - 0.42) / 0.32
        return maxHalfWidth * (1.0 - 0.05 * offset * offset)
    end

    local p = (t - 0.74) / 0.26
    return maxHalfWidth * (0.98 - 0.26 * p * p)
end

local function vesselBadge(vessel, state)
    vessel = vessel or {}
    state = state or {}

    if vessel.type == "locked" then
        return {
            kind = "locked",
        }
    end
    if vessel.type == "oneway" and vessel.mode == "in" then
        return {
            kind = "in",
        }
    end
    if vessel.type == "oneway" and vessel.mode == "out" then
        return {
            kind = "out",
        }
    end
    if vessel.type == "cracked" then
        local remaining = math.max(0, (tonumber(vessel.maxSourceUses) or 1) - (tonumber(state.sourceUses) or 0))
        return {
            kind = "cracked",
            remaining = remaining,
        }
    end
    return nil
end

local function drawBadgeBackground(nvg, x, y, size, color)
    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, x, y, size, size, math.max(8, size * 0.34))
    nvgFillColor(nvg, nvgRGBA(color[1], color[2], color[3], 236))
    nvgFill(nvg)
end

local function drawLockedIcon(nvg, x, y, size)
    local stroke = math.max(2, size * 0.08)
    local shackleTop = y + size * 0.2
    local shackleBase = y + size * 0.5
    local centerX = x + size * 0.5
    local shackleHalf = size * 0.16

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, centerX - shackleHalf, shackleBase)
    nvgBezierTo(
        nvg,
        centerX - shackleHalf, shackleTop,
        centerX + shackleHalf, shackleTop,
        centerX + shackleHalf, shackleBase
    )
    nvgStrokeColor(nvg, nvgRGBA(255, 255, 255, 255))
    nvgStrokeWidth(nvg, stroke)
    nvgStroke(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(
        nvg,
        x + size * 0.24,
        y + size * 0.46,
        size * 0.52,
        size * 0.28,
        math.max(4, size * 0.08)
    )
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 255))
    nvgFill(nvg)
end

local function drawArrowIcon(nvg, x, y, size, direction)
    local centerX = x + size * 0.5
    local lineTop = y + size * 0.24
    local lineBottom = y + size * 0.76
    local arrowTip = direction == "in" and lineBottom or lineTop
    local arrowBase = direction == "in" and lineTop or lineBottom
    local triangleBaseY = direction == "in" and y + size * 0.54 or y + size * 0.46
    local triangleTipY = direction == "in" and y + size * 0.74 or y + size * 0.26

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, centerX, arrowBase)
    nvgLineTo(nvg, centerX, arrowTip)
    nvgStrokeColor(nvg, nvgRGBA(255, 255, 255, 255))
    nvgStrokeWidth(nvg, math.max(2, size * 0.08))
    nvgStroke(nvg)

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, centerX, triangleTipY)
    nvgLineTo(nvg, centerX - size * 0.16, triangleBaseY)
    nvgLineTo(nvg, centerX + size * 0.16, triangleBaseY)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, 255))
    nvgFill(nvg)
end

local function drawCrackedIcon(nvg, x, y, size, remaining)
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x + size * 0.3, y + size * 0.24)
    nvgLineTo(nvg, x + size * 0.5, y + size * 0.42)
    nvgLineTo(nvg, x + size * 0.38, y + size * 0.54)
    nvgLineTo(nvg, x + size * 0.6, y + size * 0.76)
    nvgStrokeColor(nvg, nvgRGBA(255, 255, 255, 255))
    nvgStrokeWidth(nvg, math.max(2, size * 0.08))
    nvgStroke(nvg)

    for index = 1, math.min(remaining or 0, 3) do
        local dotX = x + size * (0.26 + (index - 1) * 0.2)
        local dotY = y + size * 0.82
        nvgBeginPath(nvg)
        nvgEllipse(nvg, dotX, dotY, math.max(1.8, size * 0.05), math.max(1.8, size * 0.05))
        nvgFillColor(nvg, nvgRGBA(255, 255, 255, 255))
        nvgFill(nvg)
    end
end

local function drawBadge(nvg, badge, x, y, size, colors)
    if not badge or not badge.kind then
        return
    end

    local fillColor = colors.textPrimary
    if badge.kind == "locked" then
        fillColor = colors.coralFizz
    elseif badge.kind == "in" then
        fillColor = colors.aquaPop
    elseif badge.kind == "out" then
        fillColor = colors.mangoGlow
    elseif badge.kind == "cracked" then
        fillColor = colors.lanternRed
    end

    drawBadgeBackground(nvg, x, y, size, fillColor)

    if badge.kind == "locked" then
        drawLockedIcon(nvg, x, y, size)
        return
    end
    if badge.kind == "in" or badge.kind == "out" then
        drawArrowIcon(nvg, x, y, size, badge.kind)
        return
    end
    if badge.kind == "cracked" then
        drawCrackedIcon(nvg, x, y, size, badge.remaining)
    end
end

function PuzzleTubeWidget:Init(props)
    props = props or {}
    props.width = props.width or 76
    props.height = props.height or 156
    props.pointerEvents = "auto"
    UI.Widget.Init(self, props)

    self.tubeIndex_ = props.tubeIndex or 1
    self.capacity_ = props.capacity or 4
    self.getTube_ = props.getTube
    self.getVessel_ = props.getVessel
    self.getTubeState_ = props.getTubeState
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
    local vessel = self.getVessel_ and self.getVessel_(self.tubeIndex_) or { type = "classic" }
    local state = self.getTubeState_ and self.getTubeState_(self.tubeIndex_) or {}
    local isSelected = self.getSelectedIndex_ and self.getSelectedIndex_() == self.tubeIndex_
    local shiftY = isSelected and -layout.h * 0.05 or 0
    local padX = math.max(6, layout.w * 0.18)
    local headroom = math.max(14, layout.h * 0.14)
    local bottomPad = math.max(14, layout.h * 0.1)
    local bodyX = layout.x + padX
    local bodyY = layout.y + headroom + shiftY
    local bodyW = layout.w - padX * 2
    local bodyH = layout.h - headroom - bottomPad
    local neckW = bodyW * 0.34
    local neckH = bodyH * 0.12
    local neckX = bodyX + (bodyW - neckW) * 0.5
    local neckY = bodyY + 2
    local capW = bodyW * 0.56
    local capH = math.max(10, bodyH * 0.09)
    local capX = bodyX + (bodyW - capW) * 0.5
    local capY = bodyY - capH + 6
    local earBaseY = bodyY + neckH * 0.78
    local earTipY = bodyY - math.max(6, bodyH * 0.08)
    local leftEarLeft = bodyX + bodyW * 0.16
    local leftEarTip = bodyX + bodyW * 0.3
    local leftEarRight = neckX - 3
    local rightEarLeft = neckX + neckW + 3
    local rightEarTip = bodyX + bodyW * 0.7
    local rightEarRight = bodyX + bodyW * 0.84
    local bottleTop = bodyY + neckH * 0.64
    local bottleBottom = bodyY + bodyH
    local bottleCenterX = bodyX + bodyW * 0.5
    local bellyHalfWidth = bodyW * 0.34
    local liquidTopY = bottleTop + bodyH * 0.12
    local liquidBottomY = bottleBottom - bodyH * 0.06
    local liquidHeight = math.max(8, liquidBottomY - liquidTopY)
    local layerH = liquidHeight / self.capacity_
    local shadowAlpha = self.hovered_ and 54 or 34
    local dimmed = state.dimmed and 1 or 0
    local glassAlpha = dimmed == 1 and 164 or 228
    local strokeAlpha = dimmed == 1 and 132 or (isSelected and 235 or 186)
    local badge = vesselBadge(vessel, state)

    nvgBeginPath(nvg)
    nvgEllipse(nvg, layout.x + layout.w * 0.5, layout.y + layout.h - 8 + shiftY, bodyW * 0.58, math.max(5, layout.h * 0.04))
    local shadowPaint = nvgRadialGradient(
        nvg,
        layout.x + layout.w * 0.5,
        layout.y + layout.h - 8 + shiftY,
        0,
        bodyW * 0.74,
        nvgRGBA(colors.shadowMauve[1], colors.shadowMauve[2], colors.shadowMauve[3], shadowAlpha),
        nvgRGBA(colors.shadowMauve[1], colors.shadowMauve[2], colors.shadowMauve[3], 0)
    )
    nvgFillPaint(nvg, shadowPaint)
    nvgFill(nvg)

    if isSelected then
        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, bodyX - 5, bodyY - 9, bodyW + 10, bodyH + 16, math.max(12, bodyW * 0.38))
        nvgStrokeColor(nvg, nvgRGBA(colors.mangoGlow[1], colors.mangoGlow[2], colors.mangoGlow[3], 132))
        nvgStrokeWidth(nvg, math.max(2, layout.w * 0.04))
        nvgStroke(nvg)
    end

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, leftEarLeft, earBaseY)
    nvgLineTo(nvg, leftEarTip, earTipY)
    nvgLineTo(nvg, leftEarRight, earBaseY + 2)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(255, 252, 250, dimmed == 1 and 180 or 214))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, rightEarLeft, earBaseY + 2)
    nvgLineTo(nvg, rightEarTip, earTipY)
    nvgLineTo(nvg, rightEarRight, earBaseY)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(255, 252, 250, dimmed == 1 and 180 or 214))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, capX, capY, capW, capH, math.max(5, capH * 0.5))
    nvgFillColor(nvg, nvgRGBA(187, 137, 89, dimmed == 1 and 196 or 240))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, neckX, neckY, neckW, neckH, math.max(6, neckH * 0.46))
    nvgFillColor(nvg, nvgRGBA(255, 246, 236, dimmed == 1 and 176 or 228))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX, bottleTop, bodyW, bodyH - 12, math.max(12, bodyW * 0.38))
    local bodyFill = nvgLinearGradient(
        nvg,
        bodyX,
        bottleTop,
        bodyX,
        bottleBottom,
        nvgRGBA(255, 253, 252, glassAlpha),
        nvgRGBA(223, 239, 255, dimmed == 1 and 136 or 188)
    )
    nvgFillPaint(nvg, bodyFill)
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX, bottleTop, bodyW, bodyH - 12, math.max(12, bodyW * 0.38))
    nvgStrokeColor(nvg, nvgRGBA(255, 255, 255, strokeAlpha))
    nvgStrokeWidth(nvg, math.max(1.4, layout.w * 0.025))
    nvgStroke(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX + bodyW * 0.15, bottleTop + bodyH * 0.06, bodyW * 0.7, math.max(6, bodyH * 0.06), math.max(3, bodyW * 0.08))
    nvgFillColor(nvg, nvgRGBA(colors.mangoGlow[1], colors.mangoGlow[2], colors.mangoGlow[3], dimmed == 1 and 74 or 130))
    nvgFill(nvg)

    for layerIndex = 1, #tube do
        local color = self.palette_[tube[layerIndex]] or { 255, 255, 255, 255 }
        local tBottom = (layerIndex - 1) / self.capacity_
        local tTop = layerIndex / self.capacity_
        local yBottom = liquidBottomY - (layerIndex - 1) * layerH
        local yTop = liquidBottomY - layerIndex * layerH
        local midY1 = yBottom - layerH * 0.34
        local midY2 = yBottom - layerH * 0.68
        local halfBottom = getBodyHalfWidth(bellyHalfWidth, tBottom)
        local halfTop = getBodyHalfWidth(bellyHalfWidth, tTop)
        local halfMid1 = getBodyHalfWidth(bellyHalfWidth, tBottom + (tTop - tBottom) * 0.34)
        local halfMid2 = getBodyHalfWidth(bellyHalfWidth, tBottom + (tTop - tBottom) * 0.68)

        nvgBeginPath(nvg)
        nvgMoveTo(nvg, bottleCenterX - halfBottom, yBottom)
        nvgBezierTo(
            nvg,
            bottleCenterX - halfMid1, midY1,
            bottleCenterX - halfMid2, midY2,
            bottleCenterX - halfTop, yTop
        )
        nvgLineTo(nvg, bottleCenterX + halfTop, yTop)
        nvgBezierTo(
            nvg,
            bottleCenterX + halfMid2, midY2,
            bottleCenterX + halfMid1, midY1,
            bottleCenterX + halfBottom, yBottom
        )
        nvgClosePath(nvg)

        local layerFill = nvgLinearGradient(
            nvg,
            bottleCenterX,
            yTop,
            bottleCenterX,
            yBottom,
            nvgRGBA(
                math.min(color[1] + 34, 255),
                math.min(color[2] + 34, 255),
                math.min(color[3] + 34, 255),
                dimmed == 1 and 188 or 246
            ),
            nvgRGBA(
                math.max(color[1] - 24, 0),
                math.max(color[2] - 24, 0),
                math.max(color[3] - 24, 0),
                dimmed == 1 and 186 or 250
            )
        )
        nvgFillPaint(nvg, layerFill)
        nvgFill(nvg)

        nvgBeginPath(nvg)
        nvgRoundedRect(
            nvg,
            bottleCenterX - halfTop + 4,
            yTop + 2,
            math.max(6, halfTop * 0.34),
            math.max(4, layerH - 4),
            math.max(3, layout.w * 0.05)
        )
        nvgFillColor(nvg, nvgRGBA(255, 255, 255, dimmed == 1 and 36 or 62))
        nvgFill(nvg)
    end

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, bodyX + bodyW * 0.15, bottleTop + bodyH * 0.12, math.max(4, bodyW * 0.1), bodyH * 0.62, math.max(3, bodyW * 0.05))
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, dimmed == 1 and 30 or 58))
    nvgFill(nvg)

    if badge then
        local badgeSize = math.max(18, layout.w * 0.34)
        local badgeX = layout.x + layout.w - badgeSize - 2
        local badgeY = layout.y + 2
        drawBadge(nvg, badge, badgeX, badgeY, badgeSize, colors)
    end

    if state.hasLaneRule and state.inActiveLane == false then
        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, bodyX - 2, bodyY + bodyH * 0.25, bodyW + 4, bodyH * 0.3, math.max(10, bodyW * 0.2))
        nvgFillColor(nvg, nvgRGBA(colors.textPrimary[1], colors.textPrimary[2], colors.textPrimary[3], 24))
        nvgFill(nvg)
    end
end

return PuzzleTubeWidget
