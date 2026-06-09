local ClassicRules = {}

local DEFAULT_CAPACITY = 4

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, item in pairs(value) do
        copy[key] = deepCopy(item)
    end
    return copy
end

local function normalizeTube(tube)
    if type(tube) ~= "table" then
        return {}
    end

    local normalized = {}
    for _, value in ipairs(tube) do
        if value ~= nil then
            table.insert(normalized, value)
        end
    end
    return normalized
end

local function normalizeTubes(tubes)
    if type(tubes) ~= "table" then
        return {}
    end

    local normalized = {}
    for _, tube in ipairs(tubes) do
        table.insert(normalized, normalizeTube(tube))
    end
    return normalized
end

local function normalizeVessel(vessel)
    if type(vessel) ~= "table" then
        return { type = "classic" }
    end

    return {
        type = vessel.type or "classic",
        mode = vessel.mode,
        unlockAfterCompleted = tonumber(vessel.unlockAfterCompleted) or nil,
        maxSourceUses = tonumber(vessel.maxSourceUses) or nil,
    }
end

local function normalizeVessels(vessels, tubeCount)
    local normalized = {}
    if type(vessels) ~= "table" then
        for _ = 1, tubeCount do
            table.insert(normalized, { type = "classic" })
        end
        return normalized
    end

    for index = 1, tubeCount do
        table.insert(normalized, normalizeVessel(vessels[index]))
    end
    return normalized
end

local function normalizeBoardRules(boardRules)
    if type(boardRules) ~= "table" then
        return {}
    end

    local normalized = {}
    for _, rule in ipairs(boardRules) do
        table.insert(normalized, rule)
    end
    return normalized
end

local function normalizeSourceUses(count)
    local normalized = {}
    for _ = 1, count do
        table.insert(normalized, 0)
    end
    return normalized
end

function ClassicRules.cloneBoard(board)
    board = board or {}
    local tubes = normalizeTubes(deepCopy(board.tubes))
    local vessels = normalizeVessels(deepCopy(board.vessels), #tubes)

    return {
        capacity = tonumber(board.capacity) or DEFAULT_CAPACITY,
        tubes = tubes,
        vessels = vessels,
        boardRules = normalizeBoardRules(deepCopy(board.boardRules)),
        ruleConfig = deepCopy(board.ruleConfig or {}),
        sourceUses = deepCopy(board.sourceUses or normalizeSourceUses(#tubes)),
        moveCount = tonumber(board.moveCount) or 0,
        activeLane = tonumber(board.activeLane)
            or (board.ruleConfig and board.ruleConfig.elevator and board.ruleConfig.elevator.startLane)
            or 1,
    }
end

function ClassicRules.createBoard(level)
    level = level or {}
    local board = level.board or {}
    local mechanics = level.mechanics or {}
    local tubes = normalizeTubes(deepCopy(board.tubes))

    return {
        capacity = tonumber(board.capacity) or DEFAULT_CAPACITY,
        tubes = tubes,
        vessels = normalizeVessels(deepCopy(mechanics.vessels), #tubes),
        boardRules = normalizeBoardRules(deepCopy(mechanics.boardRules)),
        ruleConfig = deepCopy(mechanics.ruleConfig or {}),
        sourceUses = normalizeSourceUses(#tubes),
        moveCount = 0,
        activeLane = mechanics
            and mechanics.ruleConfig
            and mechanics.ruleConfig.elevator
            and tonumber(mechanics.ruleConfig.elevator.startLane)
            or 1,
    }
end

function ClassicRules.getVessel(board, tubeIndex)
    if type(board) ~= "table" or type(board.vessels) ~= "table" then
        return { type = "classic" }
    end
    return board.vessels[tubeIndex] or { type = "classic" }
end

function ClassicRules.getSourceUseCount(board, tubeIndex)
    if type(board) ~= "table" or type(board.sourceUses) ~= "table" then
        return 0
    end
    return tonumber(board.sourceUses[tubeIndex]) or 0
end

function ClassicRules.getTopColor(tube)
    if type(tube) ~= "table" or #tube == 0 then
        return nil
    end
    return tube[#tube]
end

function ClassicRules.getTopCount(tube)
    if type(tube) ~= "table" or #tube == 0 then
        return 0
    end

    local color = tube[#tube]
    local count = 0
    for index = #tube, 1, -1 do
        if tube[index] ~= color then
            break
        end
        count = count + 1
    end
    return count
end

function ClassicRules.countCompletedTubes(board)
    if type(board) ~= "table" or type(board.tubes) ~= "table" then
        return 0
    end

    local capacity = tonumber(board.capacity) or DEFAULT_CAPACITY
    local complete = 0
    for _, tube in ipairs(board.tubes) do
        if #tube == capacity then
            local sameColor = true
            for index = 2, #tube do
                if tube[index] ~= tube[1] then
                    sameColor = false
                    break
                end
            end
            if sameColor then
                complete = complete + 1
            end
        end
    end
    return complete
end

local function getCompletedCount(board)
    return ClassicRules.countCompletedTubes(board)
end

local function getElevatorLane(board)
    local elevator = board and board.ruleConfig and board.ruleConfig.elevator
    if type(elevator) ~= "table" or type(elevator.lanes) ~= "table" then
        return nil
    end
    local laneIndex = tonumber(board.activeLane) or tonumber(elevator.startLane) or 1
    return elevator.lanes[laneIndex], laneIndex, #elevator.lanes
end

function ClassicRules.isSourceAllowed(board, tubeIndex)
    if type(board) ~= "table" or type(board.tubes) ~= "table" then
        return false, "invalid_board"
    end

    local tube = board.tubes[tubeIndex]
    if not tube then
        return false, "invalid_tube"
    end
    if #tube == 0 then
        return false, "empty_source"
    end

    local vessel = ClassicRules.getVessel(board, tubeIndex)
    if vessel.type == "locked" then
        local unlockAfter = tonumber(vessel.unlockAfterCompleted) or 1
        if getCompletedCount(board) < unlockAfter then
            return false, "source_locked"
        end
    end
    if vessel.type == "oneway" and vessel.mode == "in" then
        return false, "source_oneway_in"
    end
    if vessel.type == "cracked" then
        local maxSourceUses = tonumber(vessel.maxSourceUses) or 1
        if ClassicRules.getSourceUseCount(board, tubeIndex) >= maxSourceUses then
            return false, "source_cracked_spent"
        end
    end

    local lane = getElevatorLane(board)
    if lane then
        local activeLane = lane
        local allowed = false
        for _, index in ipairs(activeLane) do
            if index == tubeIndex then
                allowed = true
                break
            end
        end
        if not allowed then
            return false, "source_inactive_lane"
        end
    end

    return true
end

function ClassicRules.isTargetAllowed(board, tubeIndex)
    if type(board) ~= "table" or type(board.tubes) ~= "table" then
        return false, "invalid_board"
    end

    local tube = board.tubes[tubeIndex]
    if not tube then
        return false, "invalid_tube"
    end

    local vessel = ClassicRules.getVessel(board, tubeIndex)
    if vessel.type == "locked" then
        local unlockAfter = tonumber(vessel.unlockAfterCompleted) or 1
        if getCompletedCount(board) < unlockAfter then
            return false, "target_locked"
        end
    end
    if vessel.type == "oneway" and vessel.mode == "out" then
        return false, "target_oneway_out"
    end

    return true
end

function ClassicRules.canPour(board, fromIndex, toIndex)
    if type(board) ~= "table" or type(board.tubes) ~= "table" then
        return false, "invalid_board"
    end
    if fromIndex == toIndex then
        return false, "same_tube"
    end

    local sourceAllowed, sourceReason = ClassicRules.isSourceAllowed(board, fromIndex)
    if not sourceAllowed then
        return false, sourceReason
    end

    local targetAllowed, targetReason = ClassicRules.isTargetAllowed(board, toIndex)
    if not targetAllowed then
        return false, targetReason
    end

    local fromTube = board.tubes[fromIndex]
    local toTube = board.tubes[toIndex]
    local capacity = tonumber(board.capacity) or DEFAULT_CAPACITY

    if not fromTube or not toTube then
        return false, "invalid_tube"
    end
    if #toTube >= capacity then
        return false, "target_full"
    end
    if #toTube == 0 then
        return true
    end
    if ClassicRules.getTopColor(fromTube) ~= ClassicRules.getTopColor(toTube) then
        return false, "color_mismatch"
    end
    return true
end

local function rotateGroup(board, group, direction)
    if type(group) ~= "table" or #group < 2 then
        return
    end

    if direction == -1 then
        local firstIndex = group[1]
        local firstTube = board.tubes[firstIndex]
        local firstVessel = board.vessels[firstIndex]
        local firstUses = board.sourceUses[firstIndex]
        for index = 1, #group - 1 do
            local current = group[index]
            local nextIndex = group[index + 1]
            board.tubes[current] = board.tubes[nextIndex]
            board.vessels[current] = board.vessels[nextIndex]
            board.sourceUses[current] = board.sourceUses[nextIndex]
        end
        local lastIndex = group[#group]
        board.tubes[lastIndex] = firstTube
        board.vessels[lastIndex] = firstVessel
        board.sourceUses[lastIndex] = firstUses
        return
    end

    local lastIndex = group[#group]
    local lastTube = board.tubes[lastIndex]
    local lastVessel = board.vessels[lastIndex]
    local lastUses = board.sourceUses[lastIndex]
    for index = #group, 2, -1 do
        local current = group[index]
        local previous = group[index - 1]
        board.tubes[current] = board.tubes[previous]
        board.vessels[current] = board.vessels[previous]
        board.sourceUses[current] = board.sourceUses[previous]
    end
    local firstIndex = group[1]
    board.tubes[firstIndex] = lastTube
    board.vessels[firstIndex] = lastVessel
    board.sourceUses[firstIndex] = lastUses
end

local function applyBoardRules(board)
    local conveyor = board.ruleConfig and board.ruleConfig.conveyor
    if type(conveyor) == "table" and type(conveyor.groups) == "table" then
        local every = tonumber(conveyor.every) or 1
        if every > 0 and board.moveCount % every == 0 then
            local direction = tonumber(conveyor.direction) == -1 and -1 or 1
            for _, group in ipairs(conveyor.groups) do
                rotateGroup(board, group, direction)
            end
        end
    end

    local elevator = board.ruleConfig and board.ruleConfig.elevator
    if type(elevator) == "table" and type(elevator.lanes) == "table" and #elevator.lanes > 1 then
        local every = tonumber(elevator.every) or 1
        if every > 0 and board.moveCount % every == 0 then
            local laneCount = #elevator.lanes
            local current = tonumber(board.activeLane) or tonumber(elevator.startLane) or 1
            board.activeLane = current % laneCount + 1
        end
    end
end

function ClassicRules.pour(board, fromIndex, toIndex)
    local allowed, reason = ClassicRules.canPour(board, fromIndex, toIndex)
    if not allowed then
        return false, reason, 0, nil
    end

    local fromTube = board.tubes[fromIndex]
    local toTube = board.tubes[toIndex]
    local color = ClassicRules.getTopColor(fromTube)
    local capacity = tonumber(board.capacity) or DEFAULT_CAPACITY
    local moveCount = math.min(
        ClassicRules.getTopCount(fromTube),
        capacity - #toTube
    )

    for _ = 1, moveCount do
        table.remove(fromTube)
        table.insert(toTube, color)
    end

    board.moveCount = (tonumber(board.moveCount) or 0) + 1
    local vessel = ClassicRules.getVessel(board, fromIndex)
    if vessel.type == "cracked" then
        board.sourceUses[fromIndex] = ClassicRules.getSourceUseCount(board, fromIndex) + 1
    end

    applyBoardRules(board)
    return true, nil, moveCount, color
end

function ClassicRules.isSolved(board)
    if type(board) ~= "table" or type(board.tubes) ~= "table" then
        return false
    end

    local capacity = tonumber(board.capacity) or DEFAULT_CAPACITY
    for _, tube in ipairs(board.tubes) do
        if #tube > 0 then
            if #tube ~= capacity then
                return false
            end

            local color = tube[1]
            for index = 2, #tube do
                if tube[index] ~= color then
                    return false
                end
            end
        end
    end
    return true
end

function ClassicRules.getMechanicNote(level)
    if type(level) ~= "table" or type(level.mechanics) ~= "table" then
        return "经典倒水规则，不带额外机关。"
    end
    return level.mechanics.note or "经典倒水规则，不带额外机关。"
end

function ClassicRules.getActiveLaneLabel(board)
    local lane, laneIndex, laneCount = getElevatorLane(board)
    if not lane then
        return nil
    end
    return string.format("当前起倒轨道：%d / %d", laneIndex or 1, laneCount or 1)
end

return ClassicRules
