-- ============================================================================
-- 赛博之都 - 设计常量
-- ============================================================================

local Theme = {}

-- 配色
Theme.colors = {
    -- 强调色
    neonCyan     = { 0, 255, 255, 255 },
    neonCyanDim  = { 0, 180, 200, 255 },
    neonCyanGlow = { 0, 255, 255, 60 },
    neonPink     = { 255, 0, 128, 255 },
    neonPinkDim  = { 200, 0, 100, 255 },
    neonPinkGlow = { 255, 0, 128, 60 },
    electricPurple = { 147, 51, 234, 255 },

    -- 背景
    bgDark       = { 10, 10, 20, 255 },
    bgCard       = { 25, 16, 36, 200 },
    bgCardSolid  = { 25, 16, 36, 255 },
    bgOverlay    = { 0, 0, 0, 160 },
    bgNavbar     = { 12, 10, 22, 230 },

    -- 功能色
    success      = { 0, 255, 136, 255 },
    warning      = { 255, 193, 7, 255 },
    danger       = { 255, 61, 61, 255 },

    -- 文字
    textPrimary  = { 224, 230, 240, 255 },
    textSecondary = { 128, 144, 176, 255 },
    textMuted    = { 80, 90, 110, 200 },
}

-- 字号
Theme.fontSize = {
    xs   = 11,
    sm   = 13,
    base = 15,
    lg   = 18,
    xl   = 22,
    xxl  = 28,
    hero = 36,
}

-- 间距
Theme.spacing = {
    xs  = 4,
    sm  = 8,
    md  = 12,
    lg  = 16,
    xl  = 24,
    xxl = 32,
}

-- 圆角
Theme.radius = {
    sm  = 6,
    md  = 10,
    lg  = 14,
    xl  = 20,
    full = 9999,
}

-- 霓虹发光阴影预设
Theme.glow = {
    cyan = {
        { x = 0, y = 0, blur = 6, spread = 0, color = { 0, 255, 255, 80 } },
        { x = 0, y = 0, blur = 18, spread = 2, color = { 0, 255, 255, 40 } },
    },
    cyanStrong = {
        { x = 0, y = 0, blur = 8, spread = 1, color = { 0, 255, 255, 120 } },
        { x = 0, y = 0, blur = 24, spread = 4, color = { 0, 255, 255, 60 } },
        { x = 0, y = 0, blur = 40, spread = 6, color = { 0, 255, 255, 25 } },
    },
    pink = {
        { x = 0, y = 0, blur = 6, spread = 0, color = { 255, 0, 128, 80 } },
        { x = 0, y = 0, blur = 18, spread = 2, color = { 255, 0, 128, 40 } },
    },
    pinkStrong = {
        { x = 0, y = 0, blur = 8, spread = 1, color = { 255, 0, 128, 120 } },
        { x = 0, y = 0, blur = 24, spread = 4, color = { 255, 0, 128, 60 } },
    },
}

-- 背景渐变预设
Theme.gradient = {
    bgMain = {
        type = "linear",
        direction = "to-bottom",
        from = { 10, 10, 20, 255 },
        to = { 20, 12, 35, 255 },
    },
    cyanToPurple = {
        type = "linear",
        direction = "to-right",
        from = { 0, 200, 220, 255 },
        to = { 147, 51, 234, 255 },
    },
    pinkToPurple = {
        type = "linear",
        direction = "to-right",
        from = { 255, 0, 128, 255 },
        to = { 147, 51, 234, 255 },
    },
}

-- 过渡动画预设
Theme.transition = {
    fast = "all 0.15s easeOut",
    normal = "all 0.25s easeOut",
    slow = "all 0.4s easeOut",
    spring = "all 0.35s easeOutBack",
}

return Theme
