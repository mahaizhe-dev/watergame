local StarterLevels = {
    chapter = {
        id = "chapter01",
        name = "甜爪乐园",
        districtName = "云朵猫镇",
        tagline = "帮小猫把彩虹瓶子整理整齐。",
    },

    levels = {
        {
            id = "chapter01-level01",
            title = "奶油广场",
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
            title = "毛线小桥",
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
            title = "猫耳索道",
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
