local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")

local DistrictBackdrop = UI.Widget:Extend("DistrictBackdrop")

function DistrictBackdrop:Init(props)
    props = props or {}
    props.width = "100%"
    props.height = "100%"
    props.position = "absolute"
    props.top = 0
    props.left = 0
    props.pointerEvents = "none"
    UI.Widget.Init(self, props)

    self.time_ = 0
end

function DistrictBackdrop:Update(dt)
    self.time_ = self.time_ + dt
end

local function drawCloud(nvg, x, y, scale, alpha)
    nvgBeginPath(nvg)
    nvgCircle(nvg, x, y, 24 * scale)
    nvgCircle(nvg, x + 22 * scale, y - 10 * scale, 20 * scale)
    nvgCircle(nvg, x + 48 * scale, y, 26 * scale)
    nvgCircle(nvg, x + 24 * scale, y + 12 * scale, 24 * scale)
    nvgFillColor(nvg, nvgRGBA(255, 255, 255, alpha))
    nvgFill(nvg)
end

local function drawPillow(nvg, x, y, w, h, fillRgba, stitchRgba)
    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, x, y, w, h, math.min(w, h) * 0.26)
    nvgFillColor(nvg, fillRgba)
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, x + 3, y + 3, w - 6, h - 6, math.min(w, h) * 0.22)
    nvgStrokeColor(nvg, stitchRgba)
    nvgStrokeWidth(nvg, 1.2)
    nvgStroke(nvg)
end

local function drawBottleToy(nvg, x, y, w, h, color)
    local neckW = w * 0.34
    local neckX = x + (w - neckW) * 0.5
    local neckH = h * 0.2
    local bodyY = y + neckH - 2
    local bodyH = h - neckH
    local liquidH = bodyH * 0.42

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, neckX, y, neckW, neckH, 8)
    nvgFillColor(nvg, nvgRGBA(255, 246, 233, 210))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, x, bodyY, w, bodyH, 18)
    nvgFillColor(nvg, nvgRGBA(255, 252, 249, 176))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, x, bodyY, w, bodyH, 18)
    nvgStrokeColor(nvg, nvgRGBA(255, 255, 255, 150))
    nvgStrokeWidth(nvg, 1.4)
    nvgStroke(nvg)

    nvgSave(nvg)
    nvgScissor(nvg, x + 4, bodyY + 8, w - 8, bodyH - 12)
    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, x + 4, bodyY + bodyH - liquidH, w - 8, liquidH + 10, 12)
    nvgFillColor(nvg, color)
    nvgFill(nvg)
    nvgRestore(nvg)
end

function DistrictBackdrop:Render(nvg)
    local l = self:GetAbsoluteLayout()
    if not l or l.w <= 0 or l.h <= 0 then
        return
    end

    local w = l.w
    local h = l.h
    local t = self.time_
    local colors = ThemeTokens.colors

    nvgBeginPath(nvg)
    nvgRect(nvg, l.x, l.y, w, h)
    local sky = nvgLinearGradient(
        nvg,
        l.x,
        l.y,
        l.x,
        l.y + h,
        nvgRGBA(colors.skyWash[1], colors.skyWash[2], colors.skyWash[3], 255),
        nvgRGBA(colors.creamGlow[1], colors.creamGlow[2], colors.creamGlow[3], 255)
    )
    nvgFillPaint(nvg, sky)
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgCircle(nvg, l.x + w * 0.8, l.y + h * 0.16, w * 0.1)
    local glow = nvgRadialGradient(
        nvg,
        l.x + w * 0.8,
        l.y + h * 0.16,
        0,
        w * 0.14,
        nvgRGBA(255, 244, 211, 180),
        nvgRGBA(255, 244, 211, 0)
    )
    nvgFillPaint(nvg, glow)
    nvgFill(nvg)

    drawCloud(nvg, l.x + w * 0.08, l.y + h * 0.15, 1.15, 210)
    drawCloud(nvg, l.x + w * 0.52, l.y + h * 0.1, 1.3, 198)
    drawCloud(nvg, l.x + w * 0.72, l.y + h * 0.28, 0.95, 180)

    nvgBeginPath(nvg)
    nvgEllipse(nvg, l.x + w * 0.54, l.y + h * 0.76, w * 0.42, h * 0.08)
    local warmGlow = nvgRadialGradient(
        nvg,
        l.x + w * 0.54,
        l.y + h * 0.76,
        0,
        w * 0.44,
        nvgRGBA(colors.coralFizz[1], colors.coralFizz[2], colors.coralFizz[3], 52),
        nvgRGBA(colors.coralFizz[1], colors.coralFizz[2], colors.coralFizz[3], 0)
    )
    nvgFillPaint(nvg, warmGlow)
    nvgFill(nvg)

    drawPillow(
        nvg,
        l.x + w * 0.03,
        l.y + h * 0.62,
        w * 0.34,
        h * 0.18,
        nvgRGBA(colors.pillowMint[1], colors.pillowMint[2], colors.pillowMint[3], 206),
        nvgRGBA(255, 255, 255, 100)
    )
    drawPillow(
        nvg,
        l.x + w * 0.28,
        l.y + h * 0.66,
        w * 0.28,
        h * 0.16,
        nvgRGBA(colors.furCloud[1], colors.furCloud[2], colors.furCloud[3], 222),
        nvgRGBA(255, 255, 255, 116)
    )
    drawPillow(
        nvg,
        l.x + w * 0.58,
        l.y + h * 0.61,
        w * 0.29,
        h * 0.19,
        nvgRGBA(colors.butterBlanket[1], colors.butterBlanket[2], colors.butterBlanket[3], 196),
        nvgRGBA(255, 244, 214, 118)
    )

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, l.x - w * 0.02, l.y + h)
    nvgBezierTo(nvg, l.x + w * 0.15, l.y + h * 0.84, l.x + w * 0.34, l.y + h * 0.94, l.x + w * 0.5, l.y + h * 0.86)
    nvgBezierTo(nvg, l.x + w * 0.7, l.y + h * 0.76, l.x + w * 0.86, l.y + h * 0.9, l.x + w * 1.02, l.y + h * 0.8)
    nvgLineTo(nvg, l.x + w * 1.02, l.y + h)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(colors.furCloud[1], colors.furCloud[2], colors.furCloud[3], 235))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgMoveTo(nvg, l.x - w * 0.02, l.y + h)
    nvgBezierTo(nvg, l.x + w * 0.2, l.y + h * 0.9, l.x + w * 0.38, l.y + h * 1.01, l.x + w * 0.58, l.y + h * 0.92)
    nvgBezierTo(nvg, l.x + w * 0.78, l.y + h * 0.83, l.x + w * 0.94, l.y + h * 0.97, l.x + w * 1.02, l.y + h * 0.9)
    nvgLineTo(nvg, l.x + w * 1.02, l.y + h)
    nvgClosePath(nvg)
    nvgFillColor(nvg, nvgRGBA(255, 232, 168, 155))
    nvgFill(nvg)

    drawBottleToy(nvg, l.x + w * 0.12, l.y + h * 0.5, w * 0.065, h * 0.15, nvgRGBA(colors.aquaPop[1], colors.aquaPop[2], colors.aquaPop[3], 210))
    drawBottleToy(nvg, l.x + w * 0.26, l.y + h * 0.46, w * 0.072, h * 0.17, nvgRGBA(colors.coralFizz[1], colors.coralFizz[2], colors.coralFizz[3], 215))
    drawBottleToy(nvg, l.x + w * 0.72, l.y + h * 0.48, w * 0.07, h * 0.16, nvgRGBA(colors.jadeMint[1], colors.jadeMint[2], colors.jadeMint[3], 215))

    for index = 0, 8 do
        local sparkleX = l.x + w * (0.12 + index * 0.085)
        local sparkleY = l.y + h * (0.18 + (index % 3) * 0.035)
        local alpha = 34 + math.floor(14 * (1 + math.sin(t * 0.8 + index)))

        nvgBeginPath(nvg)
        nvgCircle(nvg, sparkleX, sparkleY, 2.1)
        nvgFillColor(nvg, nvgRGBA(colors.coralFizz[1], colors.coralFizz[2], colors.coralFizz[3], alpha))
        nvgFill(nvg)
    end
end

return DistrictBackdrop
