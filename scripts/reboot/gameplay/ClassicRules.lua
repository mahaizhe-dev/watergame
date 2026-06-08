local ClassicRules = {}

local DEFAULT_CAPACITY = 4

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

function ClassicRules.cloneBoard(board)
    board = board or {}
    return {
        capacity = tonumber(board.capacity) or DEFAULT_CAPACITY,
        tubes = normalizeTubes(deepCopy(board.tubes)),
    }
end

function ClassicRules.createBoard(level)
    level = level or {}
    local board = level.board or {}
    return {
        capacity = tonumber(board.capacity) or DEFAULT_CAPACITY,
        tubes = normalizeTubes(deepCopy(board.tubes)),
    }
end

function ClassicRules.getTopColor(tube)
    if type(tube) ~= "table" then
        return nil
    end
    if #tube == 0 then
        return nil
    end
    return tube[#tube]
end

function ClassicRules.getTopCount(tube)
    if type(tube) ~= "table" then
        return 0
    end
    if #tube == 0 then
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

function ClassicRules.canPour(board, fromIndex, toIndex)
    if type(board) ~= "table" or type(board.tubes) ~= "table" then
        return false, "invalid_board"
    end
    if fromIndex == toIndex then
        return false, "same_tube"
    end

    local fromTube = board.tubes[fromIndex]
    local toTube = board.tubes[toIndex]
    local capacity = tonumber(board.capacity) or DEFAULT_CAPACITY

    if not fromTube or not toTube then
        return false, "invalid_tube"
    end
    if #fromTube == 0 then
        return false, "empty_source"
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

return ClassicRules
