local UI = require("urhox-libs/UI")
local AppBlueprint = require("reboot.core.AppBlueprint")
local StarterLevels = require("reboot.data.StarterLevels")
local HomeScreen = require("reboot.screens.HomeScreen")
local ChapterSelectScreen = require("reboot.screens.ChapterSelectScreen")
local LevelSelectScreen = require("reboot.screens.LevelSelectScreen")
local PuzzleScreen = require("reboot.screens.PuzzleScreen")

local AppRouter = {}

local function clampLevelIndex(levels, index)
    return math.max(1, math.min(#levels, index or 1))
end

function AppRouter.Create()
    local router = {}
    local host = UI.Panel {
        width = "100%",
        height = "100%",
    }

    local progress = {
        currentLevelIndex = 1,
        unlockedLevelCount = 1,
    }

    local chapter = StarterLevels.chapter
    local levels = StarterLevels.levels
    local currentRoute = nil
    local currentScreen = nil

    local function markLevelFocused(levelIndex)
        progress.currentLevelIndex = clampLevelIndex(levels, levelIndex)
    end

    local function markLevelCleared(levelIndex)
        progress.currentLevelIndex = clampLevelIndex(levels, levelIndex)
        progress.unlockedLevelCount = math.min(
            #levels,
            math.max(progress.unlockedLevelCount, levelIndex + 1)
        )
    end

    local function mountScreen(screen)
        currentScreen = screen
        host:ClearChildren()
        host:AddChild(screen.root)
    end

    local function navigate(route, params)
        params = params or {}
        currentRoute = route

        if route == AppBlueprint.routes.home then
            mountScreen(HomeScreen.Create {
                chapter = chapter,
                progress = progress,
                onContinue = function()
                    navigate(AppBlueprint.routes.puzzle, {
                        levelIndex = progress.currentLevelIndex,
                    })
                end,
                onOpenChapters = function()
                    navigate(AppBlueprint.routes.chapterSelect)
                end,
            })
            return
        end

        if route == AppBlueprint.routes.chapterSelect then
            mountScreen(ChapterSelectScreen.Create {
                chapter = chapter,
                levels = levels,
                progress = progress,
                onBack = function()
                    navigate(AppBlueprint.routes.home)
                end,
                onSelectChapter = function()
                    navigate(AppBlueprint.routes.levelSelect)
                end,
            })
            return
        end

        if route == AppBlueprint.routes.levelSelect then
            mountScreen(LevelSelectScreen.Create {
                chapter = chapter,
                levels = levels,
                progress = progress,
                onBack = function()
                    navigate(AppBlueprint.routes.chapterSelect)
                end,
                onSelectLevel = function(levelIndex)
                    navigate(AppBlueprint.routes.puzzle, {
                        levelIndex = levelIndex,
                    })
                end,
            })
            return
        end

        if route == AppBlueprint.routes.puzzle then
            mountScreen(PuzzleScreen.Create {
                chapter = chapter,
                levels = levels,
                progress = progress,
                levelIndex = clampLevelIndex(levels, params.levelIndex or progress.currentLevelIndex),
                onBack = function()
                    navigate(AppBlueprint.routes.levelSelect)
                end,
                onOpenHome = function()
                    navigate(AppBlueprint.routes.home)
                end,
                onOpenLevels = function()
                    navigate(AppBlueprint.routes.levelSelect)
                end,
                onLevelFocus = function(levelIndex)
                    markLevelFocused(levelIndex)
                end,
                onLevelClear = function(levelIndex)
                    markLevelCleared(levelIndex)
                end,
            })
            return
        end
    end

    router.root = UI.Panel {
        width = "100%",
        height = "100%",
        children = { host },
    }

    function router.Navigate(route, params)
        navigate(route, params)
    end

    function router.HandleKey(key)
        if currentScreen and currentScreen.HandleKey and currentScreen.HandleKey(key) then
            return
        end

        if key == KEY_ESCAPE and currentRoute ~= AppBlueprint.routes.home then
            navigate(AppBlueprint.routes.home)
        end
    end

    navigate(AppBlueprint.routes.home)
    return router
end

return AppRouter
