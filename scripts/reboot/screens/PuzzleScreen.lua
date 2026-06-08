local UI = require("urhox-libs/UI")
local ThemeTokens = require("reboot.design.ThemeTokens")
local ClassicRules = require("reboot.gameplay.ClassicRules")
local DistrictBackdrop = require("reboot.ui.DistrictBackdrop")
local PuzzleTubeWidget = require("reboot.ui.PuzzleTubeWidget")
local SoftButton = require("reboot.ui.SoftButton")
local StatChip = require("reboot.ui.StatChip")
local GlassCard = require("reboot.ui.GlassCard")

local PuzzleScreen = {}

local palette = {
    aqua = { 139, 210, 218, 255 },
    coral = { 247, 164, 176, 255 },
    mint = { 181, 224, 202, 255 },
    amber = { 255, 208, 121, 255 },
}

local function getLevelTitle(level)
    return level and level.title or "未配置关卡"
end

local function getMoveBudget(level)
    return level and level.goals and level.goals.bonus and level.goals.bonus.moveBudget or 0
end

local function getChapterName(chapter)
    return chapter and chapter.name or "第一章"
end

local function getDistrictName(chapter)
    return chapter and chapter.districtName or "云朵猫镇"
end

local function getChapterTagline(chapter)
    return chapter and chapter.tagline or "帮小猫把彩虹瓶子分好类吧。"
end

local function clampLevelIndex(levels, index)
    if #levels == 0 then
        return 1
    end
    return math.max(1, math.min(#levels, index or 1))
end

local function createFallbackLevel()
    return {
        id = "missing-level",
        title = "未配置关卡",
        board = {
            capacity = 4,
            tubes = {},
        },
        goals = {
            primary = "sort_all_colors",
            bonus = { moveBudget = 0 },
        },
    }
end

local function resolveLevel(levels, index)
    local levelIndex = clampLevelIndex(levels, index)
    return levelIndex, levels[levelIndex] or createFallbackLevel()
end

local function statusMessageForReason(reason)
    if reason == "empty_source" then
        return "这个瓶子是空的，请先选择有颜色的瓶子。"
    end
    if reason == "target_full" then
        return "目标瓶子已经满了。"
    end
    if reason == "color_mismatch" then
        return "只有相同颜色才能继续叠放。"
    end
    if reason == "invalid_tube" then
        return "当前瓶子不可操作，请重新点选。"
    end
    if reason == "invalid_board" then
        return "当前关卡数据有问题，已经自动拦截。"
    end
    return "这个落点不合适，再试试别的位置。"
end

function PuzzleScreen.Create(ctx)
    ctx = ctx or {}

    local controller = {}
    local chapter = ctx.chapter or { name = "第一章", districtName = "乐园", tagline = "" }
    local levelSet = ctx.levels or {}
    local refs = {}
    local initialLevelIndex, initialLevel = resolveLevel(levelSet, ctx.levelIndex)
    local state = {
        levelIndex = initialLevelIndex,
        level = initialLevel,
        board = nil,
        history = {},
        selectedTube = nil,
        moves = 0,
        status = "帮小猫把彩虹瓶子分好类吧。",
        completed = false,
    }

    local function refreshStatusOnly()
        if refs.statusValue then
            refs.statusValue:SetText(state.status)
        end
    end

    local function refreshStats()
        local board = state.board or { tubes = {} }
        local goal = getMoveBudget(state.level)

        if refs.chapterValue then
            refs.chapterValue:SetText(getChapterName(chapter))
        end
        if refs.levelValue then
            refs.levelValue:SetText(string.format("%02d", state.levelIndex))
        end
        if refs.movesValue then
            refs.movesValue:SetText(tostring(state.moves))
        end
        if refs.goalValue then
            refs.goalValue:SetText(tostring(goal))
        end
        if refs.statusValue then
            refs.statusValue:SetText(state.status)
        end
        if refs.progressValue then
            local complete = state.board and ClassicRules.countCompletedTubes(state.board) or 0
            refs.progressValue:SetText(string.format("%d/%d", complete, #board.tubes))
        end
        if refs.levelTitle then
            refs.levelTitle:SetText(getLevelTitle(state.level))
        end
    end

    local function rebuildBoard()
        if not refs.boardGrid then
            return
        end

        refs.boardGrid:ClearChildren()
        if not state.board or not state.board.tubes or #state.board.tubes == 0 then
            refs.boardGrid:AddChild(UI.Label {
                text = "当前关卡还没有瓶子配置，页面已安全兜底。",
                fontSize = ThemeTokens.typography.body,
                fontColor = ThemeTokens.colors.textSecondary,
            })
            return
        end

        for index = 1, #state.board.tubes do
            refs.boardGrid:AddChild(PuzzleTubeWidget {
                tubeIndex = index,
                capacity = state.board.capacity,
                palette = palette,
                getTube = function(tubeIndex)
                    return state.board.tubes[tubeIndex]
                end,
                getSelectedIndex = function()
                    return state.selectedTube
                end,
                onTap = function(tubeIndex)
                    controller.HandleTubeTap(tubeIndex)
                end,
            })
        end
    end

    local function refreshView()
        rebuildBoard()
        refreshStats()
    end

    local function runGuarded(actionName, callback)
        local ok, err = pcall(callback)
        if ok then
            return true
        end

        print(string.format("[PuzzleScreen] %s failed: %s", actionName, tostring(err)))
        state.selectedTube = nil
        state.status = "操作出现了一点小问题，已经自动恢复，请再试一次。"

        local refreshOk = pcall(refreshView)
        if not refreshOk then
            pcall(refreshStatusOnly)
        end
        return false
    end

    local function resetLevel(levelIndex)
        state.levelIndex, state.level = resolveLevel(levelSet, levelIndex)
        state.board = ClassicRules.createBoard(state.level)
        state.history = {}
        state.selectedTube = nil
        state.moves = 0
        state.completed = false
        state.status = "帮小猫把彩虹瓶子分好类吧。"

        if ctx.onLevelFocus then
            ctx.onLevelFocus(state.levelIndex)
        end

        refreshView()
    end

    function controller.HandleTubeTap(index)
        return runGuarded("HandleTubeTap", function()
            if state.completed or not state.board or not state.board.tubes then
                return
            end

            if type(index) ~= "number" or index < 1 then
                state.status = "当前瓶子不可操作，请重新点选。"
                refreshStats()
                return
            end

            local tube = state.board.tubes[index]
            if not tube then
                state.selectedTube = nil
                state.status = "当前瓶子不可操作，请重新点选。"
                refreshView()
                return
            end

            if state.selectedTube == nil then
                if #tube > 0 then
                    state.selectedTube = index
                    state.status = "已选中瓶子，请点击目标瓶子进行倒水。"
                else
                    state.status = "空瓶子不能作为起点。"
                end
                refreshView()
                return
            end

            if state.selectedTube == index then
                state.selectedTube = nil
                state.status = "已取消选择。"
                refreshView()
                return
            end

            local allowed, reason = ClassicRules.canPour(state.board, state.selectedTube, index)
            if not allowed then
                if #tube > 0 then
                    state.selectedTube = index
                    state.status = "已切换到新的起始瓶子。"
                else
                    state.status = statusMessageForReason(reason)
                end
                refreshView()
                return
            end

            table.insert(state.history, ClassicRules.cloneBoard(state.board))
            local success, _, count = ClassicRules.pour(state.board, state.selectedTube, index)
            if success then
                state.moves = state.moves + 1
                state.selectedTube = nil
                state.status = string.format("倒水成功，移动了 %d 层颜色。", count)
                if ClassicRules.isSolved(state.board) then
                    state.completed = true
                    state.status = "过关成功，小猫乐园又亮起了一盏灯。"
                    if ctx.onLevelClear then
                        ctx.onLevelClear(state.levelIndex)
                    end
                end
            end

            refreshView()
        end)
    end

    function controller.Undo()
        return runGuarded("Undo", function()
            if #state.history == 0 then
                state.status = "暂时没有可以撤回的操作。"
                refreshStats()
                return
            end

            state.board = table.remove(state.history)
            state.selectedTube = nil
            state.moves = math.max(0, state.moves - 1)
            state.completed = false
            state.status = "已撤回上一步。"
            refreshView()
        end)
    end

    function controller.Restart()
        return runGuarded("Restart", function()
            resetLevel(state.levelIndex)
        end)
    end

    function controller.NextLevel()
        return runGuarded("NextLevel", function()
            if not state.completed then
                state.status = "请先完成当前关卡，再进入下一关。"
                refreshStats()
                return
            end

            if state.levelIndex < #levelSet then
                resetLevel(state.levelIndex + 1)
            else
                state.status = "试玩关卡全部完成啦，接下来可以继续扩展正式章节。"
                refreshStats()
            end
        end)
    end

    function controller.HandleKey(key)
        return runGuarded("HandleKey", function()
            if key == KEY_Z then
                controller.Undo()
                return true
            elseif key == KEY_R then
                controller.Restart()
                return true
            elseif key == KEY_N then
                controller.NextLevel()
                return true
            elseif key == KEY_ESCAPE and ctx.onBack then
                ctx.onBack()
                return true
            end
            return false
        end)
    end

    refs.chapterChip = StatChip {
        label = "章节",
        value = getChapterName(chapter),
        id = "chapterValue",
        valueFontSize = ThemeTokens.typography.body,
        valueColor = ThemeTokens.colors.mistCyan,
        alignItems = "flex-start",
        minWidth = 140,
    }
    refs.chapterValue = refs.chapterChip:FindById("chapterValue")

    refs.levelChip = StatChip {
        label = "关卡",
        value = "01",
        id = "levelValue",
        valueColor = ThemeTokens.colors.mangoGlow,
        minWidth = 92,
    }
    refs.levelValue = refs.levelChip:FindById("levelValue")

    refs.movesChip = StatChip {
        label = "步数",
        value = "0",
        id = "movesValue",
        valueColor = ThemeTokens.colors.coralFizz,
        minWidth = 92,
    }
    refs.movesValue = refs.movesChip:FindById("movesValue")

    refs.goalChip = StatChip {
        label = "目标",
        value = tostring(getMoveBudget(state.level)),
        id = "goalValue",
        valueColor = ThemeTokens.colors.jadeMint,
        minWidth = 106,
    }
    refs.goalValue = refs.goalChip:FindById("goalValue")

    refs.progressChip = StatChip {
        label = "进度",
        value = "0/0",
        id = "progressValue",
        valueColor = ThemeTokens.colors.textPrimary,
        minWidth = 96,
    }
    refs.progressValue = refs.progressChip:FindById("progressValue")

    refs.statusBanner = UI.Panel {
        width = "100%",
        paddingLeft = 14,
        paddingRight = 14,
        paddingTop = 12,
        paddingBottom = 12,
        backgroundColor = { 255, 255, 255, 132 },
        borderRadius = 16,
        borderWidth = 1,
        borderColor = { 255, 255, 255, 56 },
        children = {
            UI.Label {
                id = "statusValue",
                text = state.status,
                fontSize = ThemeTokens.typography.caption,
                fontColor = ThemeTokens.colors.textPrimary,
            },
        }
    }
    refs.statusValue = refs.statusBanner:FindById("statusValue")

    refs.boardGrid = UI.Panel {
        width = "100%",
        flexDirection = "row",
        flexWrap = "wrap",
        justifyContent = "center",
        alignItems = "center",
        gap = 8,
    }

    local topBar = UI.Panel {
        width = "100%",
        flexDirection = "row",
        flexWrap = "wrap",
        justifyContent = "space-between",
        gap = 10,
        children = {
            refs.chapterChip,
            refs.levelChip,
            refs.movesChip,
            refs.goalChip,
        }
    }

    local puzzleCard = GlassCard {
        flexGrow = 1,
        gap = 16,
        paddingTop = 16,
        paddingBottom = 20,
        backgroundColor = { 255, 250, 246, 218 },
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                alignItems = "flex-start",
                children = {
                    UI.Panel {
                        flexShrink = 1,
                        gap = 4,
                        children = {
                            UI.Label {
                                text = getDistrictName(chapter),
                                fontSize = ThemeTokens.typography.caption,
                                fontColor = ThemeTokens.colors.textSecondary,
                            },
                            UI.Label {
                                id = "levelTitle",
                                text = getLevelTitle(state.level),
                                fontSize = ThemeTokens.typography.title,
                                fontColor = ThemeTokens.colors.textPrimary,
                            },
                        },
                    },
                    refs.progressChip,
                },
            },
            refs.statusBanner,
            UI.Panel {
                width = "100%",
                flexGrow = 1,
                minHeight = 360,
                justifyContent = "center",
                alignItems = "center",
                children = {
                    refs.boardGrid,
                },
            },
        },
    }
    refs.levelTitle = puzzleCard:FindById("levelTitle")

    local bottomTray = GlassCard {
        paddingTop = 16,
        paddingBottom = 16,
        gap = 12,
        backgroundColor = { 255, 250, 246, 220 },
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                gap = 8,
                children = {
                    SoftButton {
                        text = "首页",
                        width = 78,
                        height = 50,
                        accent = "violet",
                        onClick = function()
                            if ctx.onOpenHome then
                                ctx.onOpenHome()
                            end
                        end,
                    },
                    SoftButton {
                        text = "关卡",
                        width = 84,
                        height = 50,
                        accent = "warm",
                        onClick = function()
                            if ctx.onOpenLevels then
                                ctx.onOpenLevels()
                            end
                        end,
                    },
                    SoftButton {
                        text = "撤回",
                        width = 84,
                        height = 50,
                        accent = "violet",
                        onClick = function()
                            controller.Undo()
                        end,
                    },
                    SoftButton {
                        text = "重开",
                        width = 94,
                        height = 50,
                        accent = "warm",
                        onClick = function()
                            controller.Restart()
                        end,
                    },
                },
            },
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                gap = 10,
                children = {
                    UI.Label {
                        text = "把相同颜色叠在一起，让所有瓶子都变得整整齐齐。",
                        fontSize = ThemeTokens.typography.caption,
                        fontColor = ThemeTokens.colors.textSecondary,
                        width = "62%",
                    },
                    SoftButton {
                        text = "下一关",
                        width = 108,
                        height = 52,
                        accent = "mint",
                        onClick = function()
                            controller.NextLevel()
                        end,
                    },
                },
            },
        },
    }

    controller.root = UI.Panel {
        width = "100%",
        height = "100%",
        paddingLeft = 14,
        paddingRight = 14,
        paddingTop = 18,
        paddingBottom = 14,
        gap = 12,
        flexDirection = "column",
        children = {
            DistrictBackdrop {},
            UI.Panel {
                width = "100%",
                gap = 6,
                children = {
                    UI.Label {
                        text = "猫咪倒水屋",
                        fontSize = ThemeTokens.typography.hero,
                        fontColor = ThemeTokens.colors.textPrimary,
                    },
                    UI.Label {
                        text = getChapterTagline(chapter),
                        fontSize = ThemeTokens.typography.body,
                        fontColor = ThemeTokens.colors.textSecondary,
                    },
                },
            },
            topBar,
            puzzleCard,
            bottomTray,
        },
    }

    resetLevel(state.levelIndex)
    return controller
end

return PuzzleScreen
