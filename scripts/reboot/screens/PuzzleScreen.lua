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
    aqua = { 77, 207, 228, 255 },
    coral = { 255, 123, 145, 255 },
    mint = { 94, 235, 176, 255 },
    amber = { 255, 191, 84, 255 },
}

local function clampLevelIndex(levels, index)
    return math.max(1, math.min(#levels, index or 1))
end

local function statusMessageForReason(reason)
    if reason == "empty_source" then
        return "This bottle is empty. Start from one with color."
    end
    if reason == "target_full" then
        return "The target bottle is already full."
    end
    if reason == "color_mismatch" then
        return "Only matching colors can stack together."
    end
    return "Try a different landing spot."
end

function PuzzleScreen.Create(ctx)
    ctx = ctx or {}

    local controller = {}
    local chapter = ctx.chapter or { name = "Chapter 01", districtName = "District", tagline = "" }
    local levelSet = ctx.levels or {}
    local refs = {}
    local state = {
        levelIndex = clampLevelIndex(levelSet, ctx.levelIndex),
        level = levelSet[clampLevelIndex(levelSet, ctx.levelIndex)],
        board = nil,
        history = {},
        selectedTube = nil,
        moves = 0,
        status = "Tap a bottle to start sorting the district lights.",
        completed = false,
    }

    local function refreshStats()
        if refs.chapterValue then
            refs.chapterValue:SetText(chapter.name)
        end
        if refs.levelValue then
            refs.levelValue:SetText(string.format("%02d", state.levelIndex))
        end
        if refs.movesValue then
            refs.movesValue:SetText(tostring(state.moves))
        end
        if refs.goalValue then
            refs.goalValue:SetText(tostring(state.level.goals.bonus.moveBudget))
        end
        if refs.statusValue then
            refs.statusValue:SetText(state.status)
        end
        if refs.progressValue then
            local complete = ClassicRules.countCompletedTubes(state.board)
            refs.progressValue:SetText(string.format("%d/%d", complete, #state.board.tubes))
        end
        if refs.levelTitle then
            refs.levelTitle:SetText(state.level.title)
        end
    end

    local function rebuildBoard()
        if not refs.boardGrid then
            return
        end

        refs.boardGrid:ClearChildren()
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

    local function resetLevel(levelIndex)
        state.levelIndex = clampLevelIndex(levelSet, levelIndex)
        state.level = levelSet[state.levelIndex]
        state.board = ClassicRules.createBoard(state.level)
        state.history = {}
        state.selectedTube = nil
        state.moves = 0
        state.completed = false
        state.status = "Tap a bottle to start sorting the district lights."

        if ctx.onLevelFocus then
            ctx.onLevelFocus(state.levelIndex)
        end

        refreshView()
    end

    function controller.HandleTubeTap(index)
        if state.completed then
            return
        end

        local tube = state.board.tubes[index]
        if state.selectedTube == nil then
            if #tube > 0 then
                state.selectedTube = index
                state.status = "Bottle selected. Tap another bottle to pour."
            else
                state.status = "Empty bottles cannot start a move."
            end
            refreshView()
            return
        end

        if state.selectedTube == index then
            state.selectedTube = nil
            state.status = "Selection cleared."
            refreshView()
            return
        end

        local allowed, reason = ClassicRules.canPour(state.board, state.selectedTube, index)
        if not allowed then
            if #tube > 0 then
                state.selectedTube = index
                state.status = "Switching to a new source bottle."
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
            state.status = string.format("Poured successfully. Moved %d color layers.", count)
            if ClassicRules.isSolved(state.board) then
                state.completed = true
                state.status = "Level cleared. The whole district lights up again."
                if ctx.onLevelClear then
                    ctx.onLevelClear(state.levelIndex)
                end
            end
        end

        refreshView()
    end

    function controller.Undo()
        if #state.history == 0 then
            state.status = "There is nothing to undo yet."
            refreshStats()
            return
        end

        state.board = table.remove(state.history)
        state.selectedTube = nil
        state.moves = math.max(0, state.moves - 1)
        state.completed = false
        state.status = "Rolled back one move."
        refreshView()
    end

    function controller.Restart()
        resetLevel(state.levelIndex)
    end

    function controller.NextLevel()
        if not state.completed then
            state.status = "Clear this level first to unlock the next stop."
            refreshStats()
            return
        end

        if state.levelIndex < #levelSet then
            resetLevel(state.levelIndex + 1)
        else
            state.status = "Sample levels are complete. Next step is real chapter content."
            refreshStats()
        end
    end

    function controller.HandleKey(key)
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
    end

    refs.chapterChip = StatChip {
        label = "Chapter",
        value = chapter.name,
        id = "chapterValue",
        valueFontSize = ThemeTokens.typography.body,
        valueColor = ThemeTokens.colors.mistCyan,
        alignItems = "flex-start",
        minWidth = 140,
    }
    refs.chapterValue = refs.chapterChip:FindById("chapterValue")

    refs.levelChip = StatChip {
        label = "Level",
        value = "01",
        id = "levelValue",
        valueColor = ThemeTokens.colors.mangoGlow,
        minWidth = 92,
    }
    refs.levelValue = refs.levelChip:FindById("levelValue")

    refs.movesChip = StatChip {
        label = "Moves",
        value = "0",
        id = "movesValue",
        valueColor = ThemeTokens.colors.coralFizz,
        minWidth = 92,
    }
    refs.movesValue = refs.movesChip:FindById("movesValue")

    refs.goalChip = StatChip {
        label = "Target",
        value = tostring(state.level.goals.bonus.moveBudget),
        id = "goalValue",
        valueColor = ThemeTokens.colors.jadeMint,
        minWidth = 106,
    }
    refs.goalValue = refs.goalChip:FindById("goalValue")

    refs.progressChip = StatChip {
        label = "Progress",
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
        backgroundColor = { 255, 255, 255, 18 },
        borderRadius = 16,
        borderWidth = 1,
        borderColor = { 255, 255, 255, 28 },
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
                                text = chapter.districtName,
                                fontSize = ThemeTokens.typography.caption,
                                fontColor = ThemeTokens.colors.textSecondary,
                            },
                            UI.Label {
                                id = "levelTitle",
                                text = state.level.title,
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
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                gap = 8,
                children = {
                    SoftButton {
                        text = "Home",
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
                        text = "Levels",
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
                        text = "Undo",
                        width = 84,
                        height = 50,
                        accent = "violet",
                        onClick = function()
                            controller.Undo()
                        end,
                    },
                    SoftButton {
                        text = "Restart",
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
                        text = "The action tray stays in the thumb zone for portrait play.",
                        fontSize = ThemeTokens.typography.caption,
                        fontColor = ThemeTokens.colors.textSecondary,
                        width = "62%",
                    },
                    SoftButton {
                        text = "Next",
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
                        text = "Water Sort Reboot",
                        fontSize = ThemeTokens.typography.hero,
                        fontColor = ThemeTokens.colors.textPrimary,
                    },
                    UI.Label {
                        text = chapter.tagline,
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
