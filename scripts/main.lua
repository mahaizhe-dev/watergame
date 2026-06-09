local UI = require("urhox-libs/UI")
local AppRouter = require("reboot.core.AppRouter")

local controller_ = nil

function Start()
    graphics.windowTitle = "猫咪倒水屋"

    UI.Init({
        fonts = {
            { family = "sans", weights = { normal = "Fonts/MiSans-Regular.ttf" } }
        },
        scale = UI.Scale.DEFAULT,
    })

    controller_ = AppRouter.Create()
    UI.SetRoot(controller_.root)

    SubscribeToEvent("KeyDown", "HandleKeyDown")
    SubscribeToEvent("Update", "HandleUpdate")
end

function Stop()
    UI.Shutdown()
end

---@param eventType string
---@param eventData KeyDownEventData
function HandleKeyDown(eventType, eventData)
    if not controller_ then
        return
    end

    local key = eventData["Key"]:GetInt()
    controller_.HandleKey(key)
end

---@param eventType string
---@param eventData UpdateEventData
function HandleUpdate(eventType, eventData)
    if not controller_ or not controller_.HandleUpdate then
        return
    end

    local dt = eventData["TimeStep"]:GetFloat()
    controller_.HandleUpdate(dt)
end
