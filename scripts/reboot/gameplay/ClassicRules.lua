local ClassicRules = {}

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
    return {
        capacity = board.capacity,
        tubes = deepCopy(board.tubes),
    }
end

function ClassicRules.createBoard(level)
    return {
        capacity = level.board.capacity,
        tubes = deepCopy(level.board.tubes),
    }
end

function ClassicRules.getTopColor(tube)
    if #tube == 0 then
        return nil
    end
    return tube[#tube]
end

function ClassicRules.getTopCount(tube)
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
    if fromIndex == toIndex then
        return false, "same_tube"
    end

    local fromTube = board.tubes[fromIndex]
    local toTube = board.tubes[toIndex]

    if not fromTube or not toTube then
        return false, "invalid_tube"
    end
    if #fromTube == 0 then
        return false, "empty_source"
    end
    if #toTube >= board.capacity then
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
    local moveCount = math.min(
        ClassicRules.getTopCount(fromTube),
        board.capacity - #toTube
    )

    for _ = 1, moveCount do
        table.remove(fromTube)
        table.insert(toTube, color)
    end

    return true, nil, moveCount, color
end

function ClassicRules.isSolved(board)
    for _, tube in ipairs(board.tubes) do
        if #tube > 0 then
            if #tube ~= board.capacity then
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
    local complete = 0
    for _, tube in ipairs(board.tubes) do
        if #tube == board.capacity then
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
