local UI = require("urhox-libs/UI")
local AppBlueprint = require("reboot.core.AppBlueprint")
local StarterLevels = require("reboot.data.StarterLevels")
local HomeScreen = require("reboot.screens.HomeScreen")
local ChapterSelectScreen = require("reboot.screens.ChapterSelectScreen")
local LevelSelectScreen = require("reboot.screens.LevelSelectScreen")
local PuzzleScreen = require("reboot.screens.PuzzleScreen")
local ThemeTokens = require("reboot.design.ThemeTokens")
local GlassCard = require("reboot.ui.GlassCard")
local SoftButton = require("reboot.ui.SoftButton")

local AppRouter = {}

local function clampLevelIndex(levels, index)
    if #levels == 0 then
        return 1
    end
    return math.max(1, math.min(#levels, index or 1))
end

function AppRouter.Create()
    local router = {}
    local host = UI.Panel {
        width = "100%",
        height = "100%",
    }

    local chapter = StarterLevels.chapter or {}
    local levels = StarterLevels.levels or {}
    local initialUnlocked = #levels == 0 and 0 or 1

    local progress = {
        currentLevelIndex = 1,
        unlockedLevelCount = initialUnlocked,
    }
    local currentRoute = nil
    local currentScreen = nil
    local navigate

    local function markLevelFocused(levelIndex)
        progress.currentLevelIndex = clampLevelIndex(levels, levelIndex)
    end

    local function markLevelCleared(levelIndex)
        if #levels == 0 then
            progress.currentLevelIndex = 1
            progress.unlockedLevelCount = 0
            return
        end

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

    local function buildFallbackScreen(routeLabel, errMessage, onRetry, onHome)
        local colors = ThemeTokens.colors
        local safeMessage = tostring(errMessage or "未知错误")

        return {
            root = UI.Panel {
                width = "100%",
                height = "100%",
                paddingLeft = 18,
                paddingRight = 18,
                paddingTop = 24,
                paddingBottom = 24,
                justifyContent = "center",
                alignItems = "center",
                backgroundGradient = {
                    type = "linear",
                    direction = "to-bottom",
                    from = { 198, 234, 255, 255 },
                    to = { 255, 239, 227, 255 },
                },
                children = {
                    GlassCard {
                        width = "100%",
                        maxWidth = 420,
                        alignItems = "center",
                        gap = 14,
                        children = {
                            UI.Label {
                                text = "小猫打了个滚",
                                fontSize = ThemeTokens.typography.hero,
                                fontColor = colors.textPrimary,
                            },
                            UI.Label {
                                text = string.format("%s 页面出现异常，已经拦住了崩溃。", routeLabel),
                                fontSize = ThemeTokens.typography.body,
                                fontColor = colors.textSecondary,
                            },
                            UI.Label {
                                text = safeMessage,
                                fontSize = ThemeTokens.typography.caption,
                                fontColor = colors.textMuted,
                            },
                            UI.Panel {
                                width = "100%",
                                flexDirection = "row",
                                justifyContent = "space-between",
                                gap = 10,
                                children = {
                                    SoftButton {
                                        text = "返回首页",
                                        width = 140,
                                        height = 52,
                                        accent = "warm",
                                        onClick = onHome,
                                    },
                                    SoftButton {
                                        text = "再试一次",
                                        width = 140,
                                        height = 52,
                                        accent = "mint",
                                        onClick = onRetry,
                                    },
                                },
                            },
                        },
                    },
                },
            },
            HandleKey = function(key)
                if key == KEY_ESCAPE and onHome then
                    onHome()
                    return true
                end
                return false
            end,
        }
    end

    local function safeCreateScreen(routeLabel, factory, ctx, retryRoute, retryParams)
        local ok, screen = pcall(factory.Create, ctx)
        if ok and screen and screen.root then
            return screen
        end

        local errMessage = ok and "页面根节点缺失" or screen
        print(string.format("[AppRouter] %s screen failed: %s", routeLabel, tostring(errMessage)))

        return buildFallbackScreen(
            routeLabel,
            errMessage,
            function()
                navigate(retryRoute, retryParams)
            end,
            function()
                navigate(AppBlueprint.routes.home, {})
            end
        )
    end

    navigate = function(route, params)
        params = params or {}
        currentRoute = route

        if route == AppBlueprint.routes.home then
            local screen = safeCreateScreen("首页", HomeScreen, {
                chapter = chapter,
                progress = progress,
                onContinue = function()
                    if #levels == 0 then
                        navigate(AppBlueprint.routes.chapterSelect, {})
                    else
                        navigate(AppBlueprint.routes.puzzle, {
                            levelIndex = progress.currentLevelIndex,
                        })
                    end
                end,
                onOpenChapters = function()
                    navigate(AppBlueprint.routes.chapterSelect, {})
                end,
            }, AppBlueprint.routes.home, params)
            mountScreen(screen)
            return
        end

        if route == AppBlueprint.routes.chapterSelect then
            local screen = safeCreateScreen("章节选择", ChapterSelectScreen, {
                chapter = chapter,
                levels = levels,
                progress = progress,
                onBack = function()
                    navigate(AppBlueprint.routes.home, {})
                end,
                onSelectChapter = function()
                    navigate(AppBlueprint.routes.levelSelect, {})
                end,
            }, AppBlueprint.routes.chapterSelect, params)
            mountScreen(screen)
            return
        end

        if route == AppBlueprint.routes.levelSelect then
            local screen = safeCreateScreen("关卡选择", LevelSelectScreen, {
                chapter = chapter,
                levels = levels,
                progress = progress,
                onBack = function()
                    navigate(AppBlueprint.routes.chapterSelect, {})
                end,
                onSelectLevel = function(levelIndex)
                    navigate(AppBlueprint.routes.puzzle, {
                        levelIndex = levelIndex,
                    })
                end,
            }, AppBlueprint.routes.levelSelect, params)
            mountScreen(screen)
            return
        end

        if route == AppBlueprint.routes.puzzle then
            local screen = safeCreateScreen("倒水玩法", PuzzleScreen, {
                chapter = chapter,
                levels = levels,
                progress = progress,
                levelIndex = clampLevelIndex(levels, params.levelIndex or progress.currentLevelIndex),
                onBack = function()
                    navigate(AppBlueprint.routes.levelSelect, {})
                end,
                onOpenHome = function()
                    navigate(AppBlueprint.routes.home, {})
                end,
                onOpenLevels = function()
                    navigate(AppBlueprint.routes.levelSelect, {})
                end,
                onLevelFocus = function(levelIndex)
                    markLevelFocused(levelIndex)
                end,
                onLevelClear = function(levelIndex)
                    markLevelCleared(levelIndex)
                end,
            }, AppBlueprint.routes.puzzle, params)
            mountScreen(screen)
            return
        end

        navigate(AppBlueprint.routes.home, {})
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
        if currentScreen and currentScreen.HandleKey then
            local ok, handled = pcall(currentScreen.HandleKey, key)
            if ok and handled then
                return
            end
            if not ok then
                print(string.format("[AppRouter] HandleKey failed on route %s: %s", tostring(currentRoute), tostring(handled)))
                navigate(AppBlueprint.routes.home, {})
                return
            end
        end

        if key == KEY_ESCAPE and currentRoute ~= AppBlueprint.routes.home then
            navigate(AppBlueprint.routes.home, {})
        end
    end

    navigate(AppBlueprint.routes.home, {})
    return router
end

return AppRouter
