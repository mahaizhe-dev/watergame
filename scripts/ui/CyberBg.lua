-- ============================================================================
-- 赛博之都背景 - 重庆天际线剪影 + 霓虹光斑粒子
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")

local CyberBg = UI.Widget:Extend("CyberBg")

-- 建筑物数据（相对比例，0~1）
local BUILDINGS = {
    -- { x比例, 宽度比例, 高度比例, 有天线 }
    { 0.02, 0.035, 0.28, false },
    { 0.06, 0.025, 0.40, true },
    { 0.09, 0.040, 0.35, false },
    { 0.14, 0.030, 0.55, true },   -- 高楼
    { 0.18, 0.045, 0.30, false },
    { 0.23, 0.025, 0.62, true },   -- 最高楼
    { 0.27, 0.035, 0.38, false },
    { 0.31, 0.040, 0.45, true },
    { 0.36, 0.030, 0.32, false },
    { 0.40, 0.025, 0.50, true },
    { 0.44, 0.045, 0.36, false },
    { 0.49, 0.030, 0.58, true },   -- 高楼
    { 0.53, 0.035, 0.33, false },
    { 0.57, 0.028, 0.42, true },
    { 0.61, 0.040, 0.48, false },
    { 0.66, 0.025, 0.56, true },
    { 0.70, 0.035, 0.30, false },
    { 0.74, 0.030, 0.44, true },
    { 0.78, 0.045, 0.38, false },
    { 0.83, 0.025, 0.52, true },
    { 0.87, 0.035, 0.34, false },
    { 0.91, 0.030, 0.46, true },
    { 0.95, 0.040, 0.28, false },
}

-- 粒子
local MAX_PARTICLES = 20

function CyberBg:Init(props)
    props = props or {}
    props.width = "100%"
    props.height = "100%"
    props.position = "absolute"
    props.top = 0
    props.left = 0
    props.pointerEvents = "none"
    UI.Widget.Init(self, props)

    -- 初始化粒子
    self.particles_ = {}
    self.time_ = 0
    for i = 1, MAX_PARTICLES do
        self:SpawnParticle(i, true)
    end
end

function CyberBg:SpawnParticle(idx, randomY)
    self.particles_[idx] = {
        x = math.random() * 1000,
        y = randomY and (math.random() * 800) or (-10),
        speed = 8 + math.random() * 15,
        size = 1.5 + math.random() * 3,
        alpha = 0.15 + math.random() * 0.35,
        drift = (math.random() - 0.5) * 10,
        -- 颜色：青/粉/紫随机
        color = ({ 1, 2, 3 })[math.random(1, 3)],
    }
end

function CyberBg:Update(dt)
    self.time_ = self.time_ + dt
    local l = self:GetAbsoluteLayout()
    if not l then return end

    for i = 1, #self.particles_ do
        local p = self.particles_[i]
        p.y = p.y + p.speed * dt
        p.x = p.x + p.drift * dt
        if p.y > l.h + 10 or p.x < -10 or p.x > l.w + 10 then
            self:SpawnParticle(i, false)
            self.particles_[i].x = math.random() * l.w
        end
    end
end

function CyberBg:Render(nvg)
    local l = self:GetAbsoluteLayout()
    if not l or l.w == 0 or l.h == 0 then return end

    local w, h = l.w, l.h

    -- 渐变背景
    nvgBeginPath(nvg)
    nvgRect(nvg, l.x, l.y, w, h)
    local bg = nvgLinearGradient(nvg, l.x, l.y, l.x, l.y + h,
        nvgRGBA(10, 10, 20, 255),
        nvgRGBA(20, 12, 35, 255))
    nvgFillPaint(nvg, bg)
    nvgFill(nvg)

    -- 天际线区域（底部 35%）
    local skylineBaseY = l.y + h * 0.72
    local skylineH = h * 0.28

    -- 底部城市光晕
    nvgBeginPath(nvg)
    nvgRect(nvg, l.x, skylineBaseY - skylineH * 0.3, w, skylineH * 1.3)
    local cityGlow = nvgLinearGradient(nvg, l.x, skylineBaseY - skylineH * 0.3, l.x, l.y + h,
        nvgRGBA(0, 0, 0, 0),
        nvgRGBA(0, 40, 50, 60))
    nvgFillPaint(nvg, cityGlow)
    nvgFill(nvg)

    -- 绘制建筑剪影
    for _, b in ipairs(BUILDINGS) do
        local bx = l.x + b[1] * w
        local bw = b[2] * w
        local bh = b[3] * skylineH
        local by = l.y + h - bh

        -- 建筑主体
        nvgBeginPath(nvg)
        nvgRect(nvg, bx, by, bw, bh)
        nvgFillColor(nvg, nvgRGBA(8, 8, 16, 240))
        nvgFill(nvg)

        -- 窗户灯光（随机散布）
        local winSize = math.max(1.5, bw * 0.12)
        local cols = math.floor(bw / (winSize * 2.5))
        local rows = math.floor(bh / (winSize * 3.5))
        if cols > 0 and rows > 0 then
            local xGap = bw / (cols + 1)
            local yGap = bh / (rows + 1)
            for r = 1, rows do
                for c = 1, cols do
                    -- 用建筑索引+行列做伪随机种子
                    local seed = (b[1] * 1000 + r * 17 + c * 31) % 100
                    if seed < 45 then -- 45% 亮灯
                        local wx = bx + c * xGap
                        local wy = by + r * yGap
                        nvgBeginPath(nvg)
                        nvgRect(nvg, wx, wy, winSize, winSize)
                        if seed < 15 then
                            -- 青色灯
                            nvgFillColor(nvg, nvgRGBA(0, 200, 220, 60 + seed))
                        elseif seed < 25 then
                            -- 粉色灯
                            nvgFillColor(nvg, nvgRGBA(220, 50, 120, 50 + seed))
                        else
                            -- 暖黄灯
                            nvgFillColor(nvg, nvgRGBA(200, 180, 100, 40 + seed))
                        end
                        nvgFill(nvg)
                    end
                end
            end
        end

        -- 天线
        if b[4] then
            nvgBeginPath(nvg)
            local antX = bx + bw * 0.5
            nvgMoveTo(nvg, antX, by)
            nvgLineTo(nvg, antX, by - bh * 0.15)
            nvgStrokeColor(nvg, nvgRGBA(80, 90, 100, 180))
            nvgStrokeWidth(nvg, 1)
            nvgStroke(nvg)

            -- 天线顶部闪烁灯
            local blink = (math.sin(self.time_ * 2 + b[1] * 20) + 1) * 0.5
            nvgBeginPath(nvg)
            nvgCircle(nvg, antX, by - bh * 0.15, 1.5)
            nvgFillColor(nvg, nvgRGBA(255, 40, 80, math.floor(100 + 155 * blink)))
            nvgFill(nvg)
        end
    end

    -- 霓虹光斑粒子
    for _, p in ipairs(self.particles_) do
        local px = l.x + p.x
        local py = l.y + p.y
        if px > l.x and px < l.x + w and py > l.y and py < l.y + h then
            nvgBeginPath(nvg)
            nvgCircle(nvg, px, py, p.size)
            local a = math.floor(p.alpha * 255)
            if p.color == 1 then
                nvgFillColor(nvg, nvgRGBA(0, 255, 255, a))
            elseif p.color == 2 then
                nvgFillColor(nvg, nvgRGBA(255, 0, 128, a))
            else
                nvgFillColor(nvg, nvgRGBA(147, 51, 234, a))
            end
            nvgFill(nvg)
        end
    end
end

return CyberBg
