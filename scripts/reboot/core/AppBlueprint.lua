local AppBlueprint = {
    routes = {
        boot = "boot",
        home = "home",
        chapterSelect = "chapter-select",
        levelSelect = "level-select",
        puzzle = "puzzle",
        results = "results",
    },

    screenStack = {
        "home",
        "chapter-select",
        "level-select",
        "puzzle",
        "results",
    },

    services = {
        "router",
        "audio",
        "save-data",
        "level-loader",
        "hint-service",
        "analytics-hooks",
    },

    puzzleHudZones = {
        top = { "chapter", "level", "goals" },
        center = { "board", "ambient-backdrop" },
        bottom = { "undo", "restart", "hint", "boosters" },
    },
}

return AppBlueprint
