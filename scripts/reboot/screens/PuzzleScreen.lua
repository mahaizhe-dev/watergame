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
    aqua = { 82, 228, 255, 255 },
    coral = { 255, 122, 186, 255 },
    mint = { 102, 241, 180, 255 },
    amber = { 255, 191, 54, 255 },
    violet = { 170, 152, 255, 255 },
    rose = { 255, 107, 124, 255 },
}

local SUCCESS_DELAY = 1.05
local CHAPTER_DELAY = 1.25
local FINAL_DELAY = 1.65

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
    return chapter and chapter.tagline or "帮小猫把彩虹瓶子整理整齐。"
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
        mechanics = {
            vessels = {},
            boardRules = { "standard" },
            ruleConfig = {},
            note = "当前关卡数据异常，页面已经安全兜底。",
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

local function getTubeMetrics(tubeCount)
    if tubeCount <= 4 then
        return { width = 88, height = 196, gap = 12, minHeight = 392 }
    end
    if tubeCount <= 6 then
        return { width = 76, height = 176, gap = 10, minHeight = 360 }
    end
    if tubeCount <= 8 then
        return { width = 68, height = 160, gap = 10, minHeight = 344 }
    end
    if tubeCount <= 10 then
        return { width = 60, height = 142, gap = 8, minHeight = 320 }
    end
    return { width = 54, height = 124, gap = 8, minHeight = 300 }
end

local function statusMessageForReason(reason)
    if reason == "empty_source" then
        return "这个瓶子是空的，请先点有颜色的瓶子。"
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
    if reason == "source_locked" or reason == "target_locked" then
        return "锁瓶还没有打开，先点亮前面的整瓶。"
    end
    if reason == "source_oneway_in" then
        return "这个箭头瓶只能接水，不能作为起始瓶。"
    end
    if reason == "target_oneway_out" then
        return "这个箭头瓶只能倒出，不能作为落点。"
    end
    if reason == "source_cracked_spent" then
        return "裂纹瓶已经用尽了起倒次数。"
    end
    if reason == "source_inactive_lane" then
        return "当前不是这条轨道的回合，请换一排起倒。"
    end
    if reason == "invalid_board" then
        return "当前关卡数据异常，页面已经安全拦截。"
    end
    return "这个落点不合适，再试试别的位置。"
end

local function canSwitchSource(reason, tube)
    if type(tube) ~= "table" or #tube == 0 then
        return false
    end
    return reason == "color_mismatch" or reason == "target_full"
end

function PuzzleScreen.Create(ctx)
    ctx = ctx or {}

    local controller = {}
    local colors = ThemeTokens.colors
    local chapter = ctx.chapter or { name = "第一章", districtName = "云朵猫镇", tagline = "帮小猫把彩虹瓶子整理整齐。" }
    local levelSet = ctx.levels or {}
    local refs = {}
    local initialLevelIndex, initialLevel = resolveLevel(levelSet, ctx.levelIndex)

    local state = {
        chapterIndex = tonumber(ctx.chapterIndex) or 1,
        levelIndex = initialLevelIndex,
        level = initialLevel,
        board = nil,
        history = {},
        selectedTube = nil,
        moves = 0,
        status = "把相同颜色叠在一起，让所有猫咪瓶都整整齐齐。",
        completed = false,
        overlayMode = nil,
        overlayTimer = nil,
        pendingAdvance = nil,
    }

    local function refreshStatusOnly()
        if refs.statusValue then
            refs.statusValue:SetText(state.status)
        end
    end

    local function mechanicNote()
        return ClassicRules.getMechanicNote(state.level)
    end

    local function clearOverlay()
        state.overlayMode = nil
        state.overlayTimer = nil
        state.pendingAdvance = nil
        if refs.overlayLayer then
            refs.overlayLayer.pointerEvents = "none"
            refs.overlayLayer:ClearChildren()
        end
    end

    local function showOverlay(title, message, accent, footer)
        if not refs.overlayLayer then
            return
        end

        refs.overlayLayer.pointerEvents = "auto"
        refs.overlayLayer:ClearChildren()
        refs.overlayLayer:AddChild(UI.Panel {
            position = "absolute",
            top = 0,
            left = 0,
            right = 0,
            bottom = 0,
            justifyContent = "center",
            alignItems = "center",
            backgroundColor = { 54, 33, 47, 78 },
            children = {
                GlassCard {
                    width = 324,
                    gap = 12,
                    alignItems = "center",
                    backgroundColor = { 255, 249, 244, 246 },
                    borderColor = { accent[1], accent[2], accent[3], 142 },
                    boxShadow = {
                        { x = 0, y = 18, blur = 30, spread = 0, color = { 101, 66, 81, 44 } },
                        { x = 0, y = 2, blur = 10, spread = 0, color = { 255, 255, 255, 48 } },
                    },
                    children = {
                        UI.Panel {
                            width = 68,
                            height = 68,
                            borderRadius = 999,
                            backgroundColor = { accent[1], accent[2], accent[3], 34 },
                            borderWidth = 2,
                            borderColor = { accent[1], accent[2], accent[3], 122 },
                            justifyContent = "center",
                            alignItems = "center",
                            children = {
                                UI.Label {
                                    text = "喵",
                                    fontSize = ThemeTokens.typography.hero,
                                    fontColor = accent,
                                },
                            },
                        },
                        UI.Label {
                            text = title,
                            fontSize = ThemeTokens.typography.title,
                            fontColor = colors.textPrimary,
                        },
                        UI.Label {
                            text = message,
                            fontSize = ThemeTokens.typography.body,
                            fontColor = colors.textSecondary,
                        },
                        UI.Label {
                            text = footer,
                            fontSize = ThemeTokens.typography.caption,
                            fontColor = accent,
                        },
                    },
                },
            },
        })
    end

    local function refreshStats()
        local board = state.board or { tubes = {} }
        local goal = getMoveBudget(state.level)

        if refs.chapterValue then
            refs.chapterValue:SetText(string.format("%02d章", state.chapterIndex))
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
        if refs.mechanicValue then
            refs.mechanicValue:SetText(mechanicNote())
        end
        if refs.chapterNameValue then
            refs.chapterNameValue:SetText(getChapterName(chapter))
        end
        if refs.laneValue then
            refs.laneValue:SetText(ClassicRules.getActiveLaneLabel(state.board) or "当前没有轨道限制。")
        end
    end

    local function tubeState(index)
        if not state.board then
            return { dimmed = false, sourceUses = 0, hasLaneRule = false, inActiveLane = true }
        end

        local sourceAllowed, sourceReason = ClassicRules.isSourceAllowed(state.board, index)
        local targetAllowed = ClassicRules.isTargetAllowed(state.board, index)
        local tube = state.board.tubes[index]
        local hasLaneRule = ClassicRules.getActiveLaneLabel(state.board) ~= nil

        return {
            sourceAllowed = sourceAllowed,
            targetAllowed = targetAllowed,
            sourceReason = sourceReason,
            sourceUses = ClassicRules.getSourceUseCount(state.board, index),
            hasLaneRule = hasLaneRule,
            inActiveLane = sourceReason ~= "source_inactive_lane",
            dimmed = state.selectedTube == nil and type(tube) == "table" and #tube > 0 and not sourceAllowed,
        }
    end

    local function rebuildBoard()
        if not refs.boardGrid then
            return
        end

        refs.boardGrid:ClearChildren()
        if not state.board or not state.board.tubes or #state.board.tubes == 0 then
            refs.boardGrid:AddChild(UI.Label {
                text = "当前关卡还没有瓶子配置，页面已经安全兜底。",
                fontSize = ThemeTokens.typography.body,
                fontColor = colors.textSecondary,
            })
            return
        end

        local metrics = getTubeMetrics(#state.board.tubes)
        refs.boardGrid.gap = metrics.gap
        if refs.boardShell then
            refs.boardShell.minHeight = metrics.minHeight
        end

        for index = 1, #state.board.tubes do
            refs.boardGrid:AddChild(PuzzleTubeWidget {
                tubeIndex = index,
                capacity = state.board.capacity,
                width = metrics.width,
                height = metrics.height,
                palette = palette,
                getTube = function(tubeIndex)
                    return state.board.tubes[tubeIndex]
                end,
                getVessel = function(tubeIndex)
                    return ClassicRules.getVessel(state.board, tubeIndex)
                end,
                getTubeState = function(tubeIndex)
                    return tubeState(tubeIndex)
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
        state.status = "刚刚那次操作出了点小问题，已经自动稳住了。"

        local refreshOk = pcall(refreshView)
        if not refreshOk then
            pcall(refreshStatusOnly)
        end
        return false
    end

    local function resetLevel(chapterIndex, levelIndex)
        state.chapterIndex = tonumber(chapterIndex) or state.chapterIndex or 1
        state.levelIndex, state.level = resolveLevel(levelSet, levelIndex)
        state.board = ClassicRules.createBoard(state.level)
        state.history = {}
        state.selectedTube = nil
        state.moves = 0
        state.completed = false
        state.status = "把相同颜色叠在一起，让所有猫咪瓶都整整齐齐。"
        clearOverlay()

        if ctx.onLevelFocus then
            ctx.onLevelFocus(state.chapterIndex, state.levelIndex)
        end

        refreshView()
    end

    local function buildAdvanceTarget()
        if state.levelIndex < #levelSet then
            return {
                chapterIndex = state.chapterIndex,
                levelIndex = state.levelIndex + 1,
                title = "闯关成功",
                message = string.format("第 %02d 关已经整理完成，马上进入下一关。", state.levelIndex),
                footer = "正在自动前往下一关...",
                delay = SUCCESS_DELAY,
                accent = colors.mangoGlow,
            }
        end

        if state.chapterIndex < (tonumber(ctx.totalChapters) or state.chapterIndex) then
            return {
                chapterIndex = state.chapterIndex + 1,
                levelIndex = 1,
                title = "章节完成",
                message = string.format("第 %02d 章已经亮灯，猫咪正在带你去下一章。", state.chapterIndex),
                footer = "正在自动前往下一章节...",
                delay = CHAPTER_DELAY,
                accent = colors.jadeMint,
            }
        end

        return nil
    end

    function controller.HandleTubeTap(index)
        return runGuarded("HandleTubeTap", function()
            if state.completed or state.overlayTimer or not state.board or not state.board.tubes then
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
                local allowed, reason = ClassicRules.isSourceAllowed(state.board, index)
                if allowed then
                    state.selectedTube = index
                    state.status = "已选中起始瓶，请点目标瓶开始倒水。"
                else
                    state.status = statusMessageForReason(reason)
                end
                refreshView()
                return
            end

            if state.selectedTube == index then
                state.selectedTube = nil
                state.status = "已取消当前选择。"
                refreshView()
                return
            end

            local allowed, reason = ClassicRules.canPour(state.board, state.selectedTube, index)
            if not allowed then
                if canSwitchSource(reason, tube) then
                    local canUseSource = ClassicRules.isSourceAllowed(state.board, index)
                    if canUseSource then
                        state.selectedTube = index
                        state.status = "已切换到新的起始瓶。"
                    else
                        state.status = statusMessageForReason(reason)
                    end
                else
                    state.status = statusMessageForReason(reason)
                end
                refreshView()
                return
            end

            table.insert(state.history, ClassicRules.cloneBoard(state.board))
            local success, _, count = ClassicRules.pour(state.board, state.selectedTube, index)
            if not success then
                return
            end

            state.moves = state.moves + 1
            state.selectedTube = nil
            state.status = string.format("倒水成功，挪动了 %d 层颜色。", count)

            if ClassicRules.isSolved(state.board) then
                state.completed = true
                if ctx.onLevelClear then
                    ctx.onLevelClear(state.chapterIndex, state.levelIndex)
                end

                local advance = buildAdvanceTarget()
                if advance then
                    state.overlayMode = "advance"
                    state.overlayTimer = advance.delay
                    state.pendingAdvance = advance
                    state.status = advance.footer
                    showOverlay(
                        advance.title,
                        advance.message,
                        advance.accent,
                        advance.footer
                    )
                else
                    state.overlayMode = "final"
                    state.overlayTimer = FINAL_DELAY
                    state.status = "全部章节已经整理完成。"
                    showOverlay(
                        "全部通关",
                        "8 章 160 关已经全部点亮，小猫把整座乐园都整理好了。",
                        colors.jadeMint,
                        "当前战役已经全部完成。"
                    )
                end
            end

            refreshView()
        end)
    end

    function controller.Undo()
        return runGuarded("Undo", function()
            if state.overlayTimer then
                return
            end

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
            clearOverlay()
            refreshView()
        end)
    end

    function controller.Restart()
        return runGuarded("Restart", function()
            resetLevel(state.chapterIndex, state.levelIndex)
        end)
    end

    function controller.Update(dt)
        if not state.overlayTimer then
            return
        end

        state.overlayTimer = math.max(0, state.overlayTimer - (dt or 0))
        if state.overlayTimer > 0 then
            return
        end

        if state.overlayMode == "advance" and state.pendingAdvance and ctx.onAutoAdvance then
            local target = state.pendingAdvance
            clearOverlay()
            ctx.onAutoAdvance(target.chapterIndex, target.levelIndex)
            return
        end

        if state.overlayMode == "final" then
            clearOverlay()
            refreshStats()
        end
    end

    function controller.HandleKey(key)
        return runGuarded("HandleKey", function()
            if key == KEY_Z then
                controller.Undo()
                return true
            elseif key == KEY_R then
                controller.Restart()
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
        value = string.format("%02d章", state.chapterIndex),
        id = "chapterValue",
        valueFontSize = ThemeTokens.typography.body,
        valueColor = colors.aquaPop,
        alignItems = "flex-start",
        minWidth = 124,
        backgroundColor = { 255, 255, 255, 214 },
    }
    refs.chapterValue = refs.chapterChip:FindById("chapterValue")

    refs.levelChip = StatChip {
        label = "关卡",
        value = "01",
        id = "levelValue",
        valueColor = colors.mangoGlow,
        minWidth = 86,
        backgroundColor = { 255, 252, 243, 218 },
    }
    refs.levelValue = refs.levelChip:FindById("levelValue")

    refs.movesChip = StatChip {
        label = "步数",
        value = "0",
        id = "movesValue",
        valueColor = colors.coralFizz,
        minWidth = 86,
        backgroundColor = { 255, 249, 251, 220 },
    }
    refs.movesValue = refs.movesChip:FindById("movesValue")

    refs.goalChip = StatChip {
        label = "目标",
        value = tostring(getMoveBudget(state.level)),
        id = "goalValue",
        valueColor = colors.jadeMint,
        minWidth = 96,
        backgroundColor = { 248, 255, 251, 220 },
    }
    refs.goalValue = refs.goalChip:FindById("goalValue")

    refs.progressChip = StatChip {
        label = "进度",
        value = "0/0",
        id = "progressValue",
        valueColor = colors.textPrimary,
        minWidth = 94,
        backgroundColor = { 255, 255, 255, 214 },
    }
    refs.progressValue = refs.progressChip:FindById("progressValue")

    refs.statusBanner = UI.Panel {
        width = "100%",
        paddingLeft = 14,
        paddingRight = 14,
        paddingTop = 12,
        paddingBottom = 12,
        backgroundColor = { 255, 255, 255, 162 },
        borderRadius = 18,
        borderWidth = 1,
        borderColor = { 255, 255, 255, 84 },
        children = {
            UI.Label {
                id = "statusValue",
                text = state.status,
                fontSize = ThemeTokens.typography.caption,
                fontColor = colors.textPrimary,
            },
        },
    }
    refs.statusValue = refs.statusBanner:FindById("statusValue")

    refs.mechanicBanner = UI.Panel {
        width = "100%",
        paddingLeft = 14,
        paddingRight = 14,
        paddingTop = 12,
        paddingBottom = 12,
        backgroundColor = { 255, 248, 242, 170 },
        borderRadius = 18,
        borderWidth = 1,
        borderColor = { 255, 255, 255, 84 },
        gap = 4,
        children = {
            UI.Label {
                text = "本关机关",
                fontSize = ThemeTokens.typography.caption,
                fontColor = colors.textSecondary,
            },
            UI.Label {
                id = "mechanicValue",
                text = mechanicNote(),
                fontSize = ThemeTokens.typography.caption,
                fontColor = colors.textPrimary,
            },
        },
    }
    refs.mechanicValue = refs.mechanicBanner:FindById("mechanicValue")

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
        },
    }

    refs.boardShell = UI.Panel {
        width = "100%",
        flexGrow = 1,
        minHeight = 320,
        justifyContent = "center",
        alignItems = "center",
        children = {
            refs.boardGrid,
        },
    }

    local puzzleCard = GlassCard {
        flexGrow = 1,
        gap = 14,
        paddingTop = 16,
        paddingBottom = 20,
        backgroundColor = { 255, 250, 246, 230 },
        borderColor = { 255, 255, 255, 160 },
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
                                fontColor = colors.textSecondary,
                            },
                            UI.Label {
                                id = "levelTitle",
                                text = getLevelTitle(state.level),
                                fontSize = ThemeTokens.typography.title,
                                fontColor = colors.textPrimary,
                            },
                        },
                    },
                    refs.progressChip,
                },
            },
            refs.statusBanner,
            refs.mechanicBanner,
            refs.boardShell,
        },
    }
    refs.levelTitle = puzzleCard:FindById("levelTitle")

    local bottomTray = GlassCard {
        paddingTop = 14,
        paddingBottom = 14,
        gap = 10,
        backgroundColor = { 255, 249, 243, 230 },
        borderColor = { 255, 255, 255, 160 },
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                gap = 8,
                children = {
                    SoftButton {
                        text = "首页",
                        width = 74,
                        height = 48,
                        accent = "violet",
                        onClick = function()
                            if ctx.onOpenHome then
                                ctx.onOpenHome()
                            end
                        end,
                    },
                    SoftButton {
                        text = "关卡",
                        width = 80,
                        height = 48,
                        accent = "warm",
                        onClick = function()
                            if ctx.onOpenLevels then
                                ctx.onOpenLevels()
                            end
                        end,
                    },
                    SoftButton {
                        text = "撤回",
                        width = 80,
                        height = 48,
                        accent = "violet",
                        onClick = function()
                            controller.Undo()
                        end,
                    },
                    SoftButton {
                        text = "重开",
                        width = 88,
                        height = 48,
                        accent = "warm",
                        onClick = function()
                            controller.Restart()
                        end,
                    },
                },
            },
            UI.Label {
                id = "laneValue",
                text = "当前没有轨道限制。",
                fontSize = ThemeTokens.typography.caption,
                fontColor = colors.textSecondary,
                width = "100%",
            },
        },
    }
    refs.laneValue = bottomTray:FindById("laneValue")

    refs.overlayLayer = UI.Panel {
        position = "absolute",
        top = 0,
        left = 0,
        right = 0,
        bottom = 0,
        pointerEvents = "none",
        children = {},
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
                gap = 4,
                children = {
                    UI.Label {
                        text = "猫咪倒水屋",
                        fontSize = ThemeTokens.typography.hero,
                        fontColor = colors.textPrimary,
                    },
                    UI.Label {
                        id = "chapterNameValue",
                        text = getChapterName(chapter),
                        fontSize = ThemeTokens.typography.body,
                        fontColor = colors.textSecondary,
                    },
                },
            },
            topBar,
            puzzleCard,
            bottomTray,
            refs.overlayLayer,
        },
    }
    refs.chapterNameValue = controller.root:FindById("chapterNameValue")

    resetLevel(state.chapterIndex, state.levelIndex)
    return controller
end

return PuzzleScreen
