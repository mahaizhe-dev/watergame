local UI = require("urhox-libs/UI")

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

local function drawHill(nvg, x, y, w, h, points, color)
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, x, y + h)
    nvgLineTo(nvg, x, y + h * points[1][2])
    for _, point in ipairs(points) do
        local px = x + w * point[1]
        local py = y + h * point[2]
        nvgLineTo(nvg, px, py)
    end
    nvgLineTo(nvg, x + w, y + h)
    nvgClosePath(nvg)
    nvgFillColor(nvg, color)
    nvgFill(nvg)
end

function DistrictBackdrop:Render(nvg)
    local l = self:GetAbsoluteLayout()
    if not l or l.w <= 0 or l.h <= 0 then
        return
    end

    local w = l.w
    local h = l.h
    local time = self.time_

    nvgBeginPath(nvg)
    nvgRect(nvg, l.x, l.y, w, h)
    local sky = nvgLinearGradient(
        nvg,
        l.x,
        l.y,
        l.x,
        l.y + h,
        nvgRGBA(11, 18, 34, 255),
        nvgRGBA(35, 30, 58, 255)
    )
    nvgFillPaint(nvg, sky)
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgCircle(nvg, l.x + w * 0.78, l.y + h * 0.2, w * 0.17)
    local moonGlow = nvgRadialGradient(
        nvg,
        l.x + w * 0.78,
        l.y + h * 0.2,
        0,
        w * 0.17,
        nvgRGBA(255, 191, 84, 80),
        nvgRGBA(255, 191, 84, 0)
    )
    nvgFillPaint(nvg, moonGlow)
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgEllipse(nvg, l.x + w * 0.5, l.y + h * 0.74, w * 0.48, h * 0.09)
    local riverGlow = nvgRadialGradient(
        nvg,
        l.x + w * 0.5,
        l.y + h * 0.74,
        0,
        w * 0.5,
        nvgRGBA(77, 207, 228, 52),
        nvgRGBA(77, 207, 228, 0)
    )
    nvgFillPaint(nvg, riverGlow)
    nvgFill(nvg)

    drawHill(nvg, l.x, l.y, w, h, {
        { 0.20, 0.60 },
        { 0.42, 0.52 },
        { 0.66, 0.58 },
        { 1.00, 0.50 },
    }, nvgRGBA(26, 36, 62, 255))

    drawHill(nvg, l.x, l.y, w, h, {
        { 0.15, 0.72 },
        { 0.35, 0.64 },
        { 0.58, 0.70 },
        { 0.82, 0.62 },
        { 1.00, 0.68 },
    }, nvgRGBA(33, 44, 72, 255))

    drawHill(nvg, l.x, l.y, w, h, {
        { 0.10, 0.84 },
        { 0.30, 0.77 },
        { 0.52, 0.81 },
        { 0.76, 0.74 },
        { 1.00, 0.78 },
    }, nvgRGBA(42, 55, 88, 255))

    for index = 0, 8 do
        local bx = l.x + w * (0.06 + index * 0.1)
        local by = l.y + h * (0.60 + (index % 3) * 0.03)
        local bw = w * (0.05 + (index % 2) * 0.015)
        local bh = h * (0.09 + (index % 4) * 0.022)

        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, bx, by, bw, bh, 8)
        nvgFillColor(nvg, nvgRGBA(24, 28, 48, 255))
        nvgFill(nvg)

        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, bx + bw * 0.18, by + bh * 0.16, bw * 0.28, bh * 0.08, 2)
        local signColor = (index % 2 == 0) and nvgRGBA(255, 123, 145, 150) or nvgRGBA(106, 236, 255, 150)
        nvgFillColor(nvg, signColor)
        nvgFill(nvg)
    end

    local lineY = l.y + h * 0.28
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, l.x + w * 0.12, lineY)
    nvgLineTo(nvg, l.x + w * 0.88, lineY + h * 0.02)
    nvgStrokeColor(nvg, nvgRGBA(132, 146, 176, 110))
    nvgStrokeWidth(nvg, 1.2)
    nvgStroke(nvg)

    local cableOffset = (math.sin(time * 0.45) * 0.5 + 0.5)
    local carX = l.x + w * (0.18 + cableOffset * 0.58)
    local carY = lineY + h * 0.01

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, carX, carY, w * 0.08, h * 0.032, 9)
    nvgFillColor(nvg, nvgRGBA(255, 194, 91, 220))
    nvgFill(nvg)

    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, carX + w * 0.012, carY + h * 0.006, w * 0.056, h * 0.013, 4)
    nvgFillColor(nvg, nvgRGBA(255, 244, 221, 170))
    nvgFill(nvg)

    for dot = 0, 10 do
        local px = l.x + w * (0.08 + dot * 0.085)
        local py = l.y + h * (0.18 + (dot % 2) * 0.02)
        local alpha = 48 + math.floor(24 * (1 + math.sin(time + dot)))
        nvgBeginPath(nvg)
        nvgCircle(nvg, px, py, 2.4)
        nvgFillColor(nvg, nvgRGBA(106, 236, 255, alpha))
        nvgFill(nvg)
    end
end

return DistrictBackdrop
