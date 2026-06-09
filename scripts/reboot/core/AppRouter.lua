local UI = require("urhox-libs/UI")
local AppBlueprint = require("reboot.core.AppBlueprint")
local CampaignData = require("reboot.data.CampaignData")
local HomeScreen = require("reboot.screens.HomeScreen")
local ChapterSelectScreen = require("reboot.screens.ChapterSelectScreen")
local LevelSelectScreen = require("reboot.screens.LevelSelectScreen")
local PuzzleScreen = require("reboot.screens.PuzzleScreen")
local ThemeTokens = require("reboot.design.ThemeTokens")
local GlassCard = require("reboot.ui.GlassCard")
local SoftButton = require("reboot.ui.SoftButton")

local AppRouter = {}

local function clamp(value, minimum, maximum)
    if maximum < minimum then
        return minimum
    end
    return math.max(minimum, math.min(maximum, value or minimum))
end

local function chapterLevels(chapters, chapterIndex)
    local chapter = chapters[chapterIndex] or {}
    return chapter.levels or {}
end

local function totalLevelCount(chapters)
    local total = 0
    for _, chapter in ipairs(chapters) do
        total = total + #(chapter.levels or {})
    end
    return total
end

function AppRouter.Create()
    local router = {}
    local host = UI.Panel {
        width = "100%",
        height = "100%",
    }

    local chapters = CampaignData.chapters or {}
    local chapterCount = #chapters
    local totalLevels = totalLevelCount(chapters)
    local currentRoute = nil
    local currentScreen = nil
    local navigate

    local progress = {
        currentChapterIndex = chapterCount > 0 and 1 or 0,
        currentLevelIndex = 1,
        unlockedChapterCount = chapterCount > 0 and 1 or 0,
        unlockedLevelsByChapter = {},
        clearedLevelsByChapter = {},
    }

    for chapterIndex = 1, chapterCount do
        progress.unlockedLevelsByChapter[chapterIndex] = chapterIndex == 1 and 1 or 0
        progress.clearedLevelsByChapter[chapterIndex] = 0
    end

    local function clampChapterIndex(chapterIndex)
        if chapterCount == 0 then
            return 1
        end
        return clamp(chapterIndex, 1, chapterCount)
    end

    local function clampLevelIndex(chapterIndex, levelIndex)
        local levels = chapterLevels(chapters, chapterIndex)
        if #levels == 0 then
            return 1
        end
        return clamp(levelIndex, 1, #levels)
    end

    local function getCurrentChapter()
        return chapters[clampChapterIndex(progress.currentChapterIndex)] or {}
    end

    local function getCurrentLevels()
        return chapterLevels(chapters, clampChapterIndex(progress.currentChapterIndex))
    end

    local function countClearedLevels()
        local total = 0
        for chapterIndex = 1, chapterCount do
            total = total + (progress.clearedLevelsByChapter[chapterIndex] or 0)
        end
        return total
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

    local function markLevelFocused(chapterIndex, levelIndex)
        progress.currentChapterIndex = clampChapterIndex(chapterIndex)
        progress.currentLevelIndex = clampLevelIndex(progress.currentChapterIndex, levelIndex)
    end

    local function ensureUnlockEntry(chapterIndex)
        if progress.unlockedLevelsByChapter[chapterIndex] == nil then
            progress.unlockedLevelsByChapter[chapterIndex] = 0
        end
        if progress.clearedLevelsByChapter[chapterIndex] == nil then
            progress.clearedLevelsByChapter[chapterIndex] = 0
        end
    end

    local function markLevelCleared(chapterIndex, levelIndex)
        chapterIndex = clampChapterIndex(chapterIndex)
        levelIndex = clampLevelIndex(chapterIndex, levelIndex)
        local levels = chapterLevels(chapters, chapterIndex)

        ensureUnlockEntry(chapterIndex)
        progress.clearedLevelsByChapter[chapterIndex] = math.max(progress.clearedLevelsByChapter[chapterIndex], levelIndex)
        progress.unlockedLevelsByChapter[chapterIndex] = math.max(
            progress.unlockedLevelsByChapter[chapterIndex],
            math.min(#levels, levelIndex + 1)
        )

        if levelIndex >= #levels and chapterIndex < chapterCount then
            ensureUnlockEntry(chapterIndex + 1)
            progress.unlockedChapterCount = math.max(progress.unlockedChapterCount, chapterIndex + 1)
            progress.unlockedLevelsByChapter[chapterIndex + 1] = math.max(
                progress.unlockedLevelsByChapter[chapterIndex + 1],
                1
            )
        else
            progress.unlockedChapterCount = math.max(progress.unlockedChapterCount, chapterIndex)
        end

        progress.currentChapterIndex = chapterIndex
        progress.currentLevelIndex = levelIndex
    end

    local function currentContinueLabel()
        if chapterCount == 0 then
            return "查看章节"
        end
        local chapter = getCurrentChapter()
        return string.format(
            "继续第 %02d 章·%s",
            progress.currentChapterIndex,
            chapter.name or "猫咪乐园"
        )
    end

    navigate = function(route, params)
        params = params or {}
        currentRoute = route

        if route == AppBlueprint.routes.home then
            local chapter = getCurrentChapter()
            local screen = safeCreateScreen("首页", HomeScreen, {
                chapter = chapter,
                progress = progress,
                totalLevels = totalLevels,
                totalCleared = countClearedLevels(),
                currentContinueLabel = currentContinueLabel(),
                onContinue = function()
                    if chapterCount == 0 then
                        navigate(AppBlueprint.routes.chapterSelect, {})
                        return
                    end
                    navigate(AppBlueprint.routes.puzzle, {
                        chapterIndex = progress.currentChapterIndex,
                        levelIndex = progress.currentLevelIndex,
                    })
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
                chapters = chapters,
                progress = progress,
                totalLevels = totalLevels,
                totalCleared = countClearedLevels(),
                onBack = function()
                    navigate(AppBlueprint.routes.home, {})
                end,
                onSelectChapter = function(chapterIndex)
                    navigate(AppBlueprint.routes.levelSelect, {
                        chapterIndex = clampChapterIndex(chapterIndex),
                    })
                end,
            }, AppBlueprint.routes.chapterSelect, params)
            mountScreen(screen)
            return
        end

        if route == AppBlueprint.routes.levelSelect then
            local chapterIndex = clampChapterIndex(params.chapterIndex or progress.currentChapterIndex)
            local chapter = chapters[chapterIndex] or {}
            local screen = safeCreateScreen("关卡选择", LevelSelectScreen, {
                chapterIndex = chapterIndex,
                chapter = chapter,
                levels = chapter.levels or {},
                progress = progress,
                onBack = function()
                    navigate(AppBlueprint.routes.chapterSelect, {})
                end,
                onSelectLevel = function(levelIndex)
                    navigate(AppBlueprint.routes.puzzle, {
                        chapterIndex = chapterIndex,
                        levelIndex = levelIndex,
                    })
                end,
            }, AppBlueprint.routes.levelSelect, params)
            mountScreen(screen)
            return
        end

        if route == AppBlueprint.routes.puzzle then
            local chapterIndex = clampChapterIndex(params.chapterIndex or progress.currentChapterIndex)
            local levels = chapterLevels(chapters, chapterIndex)
            local chapter = chapters[chapterIndex] or {}
            local levelIndex = clampLevelIndex(chapterIndex, params.levelIndex or progress.currentLevelIndex)

            local screen = safeCreateScreen("倒水玩法", PuzzleScreen, {
                chapterIndex = chapterIndex,
                totalChapters = chapterCount,
                chapter = chapter,
                levels = levels,
                progress = progress,
                levelIndex = levelIndex,
                onBack = function()
                    navigate(AppBlueprint.routes.levelSelect, {
                        chapterIndex = chapterIndex,
                    })
                end,
                onOpenHome = function()
                    navigate(AppBlueprint.routes.home, {})
                end,
                onOpenLevels = function()
                    navigate(AppBlueprint.routes.levelSelect, {
                        chapterIndex = chapterIndex,
                    })
                end,
                onLevelFocus = function(focusedChapterIndex, focusedLevelIndex)
                    markLevelFocused(focusedChapterIndex, focusedLevelIndex)
                end,
                onLevelClear = function(clearedChapterIndex, clearedLevelIndex)
                    markLevelCleared(clearedChapterIndex, clearedLevelIndex)
                end,
                onAutoAdvance = function(nextChapterIndex, nextLevelIndex)
                    progress.currentChapterIndex = clampChapterIndex(nextChapterIndex)
                    progress.currentLevelIndex = clampLevelIndex(progress.currentChapterIndex, nextLevelIndex)
                    navigate(AppBlueprint.routes.puzzle, {
                        chapterIndex = progress.currentChapterIndex,
                        levelIndex = progress.currentLevelIndex,
                    })
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

    function router.HandleUpdate(dt)
        if currentScreen and currentScreen.Update then
            local ok, err = pcall(currentScreen.Update, dt)
            if not ok then
                print(string.format("[AppRouter] Update failed on route %s: %s", tostring(currentRoute), tostring(err)))
                navigate(AppBlueprint.routes.home, {})
            end
        end
    end

    navigate(AppBlueprint.routes.home, {})
    return router
end

return AppRouter
