-- ============================================================================
-- 发光进度条 - 青→紫渐变 + 末端发光
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")

local GlowProgress = UI.Widget:Extend("GlowProgress")

function GlowProgress:Init(props)
    props = props or {}
    props.width = props.width or "100%"
    props.height = props.height or 10
    props.borderRadius = props.height and (props.height / 2) or 5
    props.backgroundColor = { 20, 18, 30, 255 }
    props.pointerEvents = "none"
    UI.Widget.Init(self, props)

    self.progress_ = props.progress or 0  -- 0~1
    self.targetProgress_ = self.progress_
    self.animSpeed_ = 3.0
end

function GlowProgress:SetProgress(val)
    self.targetProgress_ = math.max(0, math.min(1, val))
end

function GlowProgress:Update(dt)
    if math.abs(self.progress_ - self.targetProgress_) > 0.001 then
        local diff = self.targetProgress_ - self.progress_
        self.progress_ = self.progress_ + diff * self.animSpeed_ * dt
    end
end

function GlowProgress:Render(nvg)
    local l = self:GetAbsoluteLayout()
    if not l or l.w == 0 then return end

    local r = l.h / 2

    -- 槽底
    nvgBeginPath(nvg)
    nvgRoundedRect(nvg, l.x, l.y, l.w, l.h, r)
    nvgFillColor(nvg, nvgRGBA(20, 18, 30, 255))
    nvgFill(nvg)

    -- 填充条
    local fillW = l.w * self.progress_
    if fillW > 1 then
        nvgBeginPath(nvg)
        nvgRoundedRect(nvg, l.x, l.y, fillW, l.h, r)
        local grad = nvgLinearGradient(nvg, l.x, l.y, l.x + fillW, l.y,
            nvgRGBA(0, 220, 240, 255),
            nvgRGBA(147, 51, 234, 255))
        nvgFillPaint(nvg, grad)
        nvgFill(nvg)

        -- 末端发光
        nvgBeginPath(nvg)
        nvgCircle(nvg, l.x + fillW, l.y + l.h / 2, l.h * 1.5)
        local glow = nvgRadialGradient(nvg,
            l.x + fillW, l.y + l.h / 2, 0, l.h * 1.5,
            nvgRGBA(0, 255, 255, 50),
            nvgRGBA(0, 255, 255, 0))
        nvgFillPaint(nvg, glow)
        nvgFill(nvg)
    end
end

return GlowProgress
