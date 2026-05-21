local ThemeTokens = {
    colors = {
        inkNight = { 12, 18, 34, 255 },
        plumShadow = { 30, 26, 52, 255 },
        mistCyan = { 106, 236, 255, 255 },
        aquaPop = { 46, 210, 227, 255 },
        mangoGlow = { 255, 191, 84, 255 },
        coralFizz = { 255, 123, 145, 255 },
        jadeMint = { 94, 235, 176, 255 },
        cableViolet = { 138, 110, 255, 255 },
        lanternRed = { 255, 92, 97, 255 },
        cardFog = { 26, 34, 58, 224 },
        cardHighlight = { 255, 255, 255, 38 },
        textPrimary = { 244, 247, 255, 255 },
        textSecondary = { 176, 188, 210, 255 },
        textMuted = { 122, 136, 162, 255 },
    },

    typography = {
        hero = 34,
        title = 26,
        section = 20,
        body = 16,
        caption = 13,
        stat = 24,
    },

    spacing = {
        xs = 6,
        sm = 10,
        md = 14,
        lg = 20,
        xl = 28,
        xxl = 36,
    },

    radius = {
        chip = 14,
        button = 20,
        card = 24,
        tray = 30,
        tube = 26,
    },

    motion = {
        fast = "all 0.12s easeOut",
        normal = "all 0.22s easeOut",
        celebratory = "all 0.35s easeOutBack",
    },

    artDirection = {
        mood = "cute-light-sci-fi",
        cityKeywords = {
            "stacked-streets",
            "hillside-transit",
            "night-market-neon",
            "humid-river-glow",
        },
        avoid = {
            "grim-blackout-cyberpunk",
            "thin-terminal-ui",
            "sharp-hostile-panels",
        },
    },
}

return ThemeTokens
