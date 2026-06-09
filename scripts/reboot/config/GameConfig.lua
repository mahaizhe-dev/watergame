local GameConfig = {
    app = {
        codeName = "CatPourHouse",
        displayName = "猫咪倒水屋",
        orientation = "portrait",
        targetSessionSeconds = { min = 60, max = 180 },
    },

    board = {
        defaultCapacity = 4,
        minTubeCount = 5,
        maxTubeCount = 12,
        minTouchSize = 88,
        topHudHeight = 120,
        bottomBarHeight = 164,
    },

    progression = {
        chapterCount = 8,
        starsPerLevel = 3,
        defaultHintCount = 3,
        chapterSize = 20,
    },

    motion = {
        tapFeedbackMs = 100,
        pourTravelMs = 240,
        successBurstMs = 700,
    },
}

return GameConfig
