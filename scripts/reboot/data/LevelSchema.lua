local LevelSchema = {}

LevelSchema.template = {
    id = "chapter01-level01",
    chapterId = "chapter01",
    board = {
        capacity = 4,
        tubes = {
            { "pink", "cyan", "pink", "cyan" },
            { "cyan", "pink", "cyan", "pink" },
            {},
        },
    },
    mechanics = {
        vessels = {},
        liquids = {},
        boardRules = { "standard" },
    },
    goals = {
        primary = "sort_all_colors",
        bonus = {
            moveBudget = 18,
        },
    },
    presentation = {
        district = "nanbin-night-market",
        backdropVariant = "river-haze",
        soundtrack = "calm-neon",
    },
}

LevelSchema.examples = {
    tutorial01 = {
        id = "chapter01-level01",
        chapterId = "chapter01",
        board = {
            capacity = 4,
            tubes = {
                { "pink", "cyan", "pink", "cyan" },
                { "cyan", "pink", "cyan", "pink" },
                {},
            },
        },
        mechanics = {
            vessels = { "classic", "classic", "classic" },
            liquids = { "normal" },
            boardRules = { "standard" },
        },
        goals = {
            primary = "sort_all_colors",
            bonus = {
                moveBudget = 12,
            },
        },
        tutorial = {
            "tap-to-select",
            "tap-to-pour",
        },
    },
}

return LevelSchema
