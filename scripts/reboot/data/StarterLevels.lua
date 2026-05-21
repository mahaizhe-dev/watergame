local StarterLevels = {
    chapter = {
        id = "chapter01",
        name = "Mist Port Trial",
        districtName = "South Bank Neon",
        tagline = "Bring the hillside city lights back online.",
    },

    levels = {
        {
            id = "chapter01-level01",
            title = "Rail Exit",
            board = {
                capacity = 4,
                tubes = {
                    { "coral", "aqua", "coral", "aqua" },
                    { "aqua", "coral", "aqua", "coral" },
                    {},
                },
            },
            goals = {
                primary = "sort_all_colors",
                bonus = { moveBudget = 12 },
            },
        },
        {
            id = "chapter01-level02",
            title = "Bridge Rain",
            board = {
                capacity = 4,
                tubes = {
                    { "coral", "mint", "aqua", "coral" },
                    { "aqua", "coral", "mint", "aqua" },
                    { "mint", "aqua", "coral", "mint" },
                    {},
                },
            },
            goals = {
                primary = "sort_all_colors",
                bonus = { moveBudget = 18 },
            },
        },
        {
            id = "chapter01-level03",
            title = "Cable Sign",
            board = {
                capacity = 4,
                tubes = {
                    { "amber", "mint", "aqua", "coral" },
                    { "coral", "amber", "mint", "aqua" },
                    { "aqua", "coral", "amber", "mint" },
                    { "mint", "aqua", "coral", "amber" },
                    {},
                    {},
                },
            },
            goals = {
                primary = "sort_all_colors",
                bonus = { moveBudget = 26 },
            },
        },
    },
}

return StarterLevels
