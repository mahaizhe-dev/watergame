local ThemeTokens = {
    colors = {
        inkNight = { 93, 77, 83, 255 },
        plumShadow = { 136, 116, 123, 255 },
        mistCyan = { 139, 210, 218, 255 },
        aquaPop = { 110, 187, 199, 255 },
        mangoGlow = { 255, 208, 121, 255 },
        coralFizz = { 247, 164, 176, 255 },
        jadeMint = { 181, 224, 202, 255 },
        cableViolet = { 197, 187, 224, 255 },
        lanternRed = { 235, 141, 141, 255 },
        cardFog = { 255, 251, 247, 238 },
        cardHighlight = { 255, 255, 255, 148 },
        textPrimary = { 91, 74, 80, 255 },
        textSecondary = { 131, 112, 118, 255 },
        textMuted = { 175, 158, 164, 255 },
        creamGlow = { 255, 246, 238, 255 },
        skyWash = { 211, 234, 245, 255 },
        furCloud = { 241, 233, 230, 255 },
        furMask = { 141, 126, 134, 255 },
        butterBlanket = { 255, 223, 121, 255 },
        pillowMint = { 173, 219, 207, 255 },
        shadowMauve = { 138, 118, 126, 255 },
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
        button = 22,
        card = 28,
        tray = 30,
        tube = 28,
    },

    motion = {
        fast = "all 0.12s easeOut",
        normal = "all 0.22s easeOut",
        celebratory = "all 0.35s easeOutBack",
    },

    artDirection = {
        mood = "cat-town-casual",
        cityKeywords = {
            "ragdoll-cat-softness",
            "plush-pillows",
            "cat-town",
            "toy-bottles",
            "pastel-clouds",
            "cozy-casual-game",
        },
        avoid = {
            "grim-cyberpunk",
            "hard-neon-ui",
            "sharp-hostile-panels",
        },
    },
}

return ThemeTokens
