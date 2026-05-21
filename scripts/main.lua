-- ============================================================================
-- 赛博之都 · 倒水闯关 (Water Sort Puzzle - Cyber Chongqing Edition)
-- 玩法：点击杯子选中，再点击目标杯子将顶层同色液体倒入
-- 目标：让每个杯子只包含单一颜色的液体
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")
local CyberBg = require("ui.CyberBg")
local NeonButton = require("ui.NeonButton")
local HoloCard = require("ui.HoloCard")
local CyberDialog = require("ui.CyberDialog")

-- ============================================================================
-- 游戏配置
-- ============================================================================
local CONFIG = {
    CUP_CAPACITY  = 4,       -- 每杯容量（层数）
    CUP_WIDTH     = 50,      -- 杯子宽度（逻辑）
    CUP_HEIGHT    = 130,     -- 杯子高度（逻辑）
    CUP_TOP_W     = 50,      -- 杯口宽度
    CUP_BOT_W     = 40,      -- 杯底宽度
    SELECTED_LIFT = -22,     -- 选中上移量
    WAVE_SPEED    = 2.8,
    WAVE_AMP      = 1.8,
    BORDER_R      = 6,       -- 杯子圆角
}

-- 霓虹液体颜色（r,g,b）— 赛博风格高饱和
local COLORS = {
    { 255,  60,  80 },   -- 1 霓虹红
    {  40, 200, 255 },   -- 2 电光蓝
    {  60, 255, 120 },   -- 3 数据绿
    { 255, 220,  30 },   -- 4 琥珀黄
    { 200,  50, 255 },   -- 5 电光紫
    { 255, 100,  20 },   -- 6 霓虹橙
    { 255,  80, 180 },   -- 7 赛博粉
    {  40, 230, 220 },   -- 8 霓虹青
}

-- ============================================================================
-- 关卡数据 (12 关，从底到顶)
-- ============================================================================
local LEVELS = {
    { cups = { {1,2,1,2}, {2,1,2,1}, {} } },
    { cups = { {1,2,2,1}, {2,1,1,2}, {} } },
    { cups = { {1,2,1,2}, {2,1,2,1}, {}, {} } },
    { cups = { {1,2,3,1}, {3,1,2,3}, {2,3,1,2}, {} } },
    { cups = { {1,3,2,1}, {2,1,3,2}, {3,2,1,3}, {}, {} } },
    { cups = { {1,2,3,4}, {3,4,1,2}, {2,1,4,3}, {4,3,2,1}, {} } },
    { cups = { {1,3,2,4}, {4,2,1,3}, {3,1,4,2}, {2,4,3,1}, {}, {} } },
    { cups = { {1,2,3,5}, {4,5,1,2}, {3,1,5,4}, {5,4,2,3}, {2,3,4,1}, {} } },
    { cups = { {1,4,3,5}, {2,5,1,3}, {4,3,5,2}, {5,1,2,4}, {3,2,4,1}, {}, {} } },
    { cups = { {1,3,5,6}, {2,6,4,1}, {5,1,6,3}, {4,2,3,5}, {6,4,1,2}, {3,5,2,4}, {} } },
    { cups = { {1,5,3,6}, {4,6,2,1}, {3,2,5,4}, {6,1,4,5}, {2,3,6,2}, {5,4,1,3}, {}, {} } },
    { cups = { {1,3,5,7}, {2,6,4,1}, {7,1,6,3}, {4,2,3,5}, {6,7,1,2}, {3,5,7,4}, {5,4,2,6}, {} } },
}

-- ============================================================================
-- 游戏状态
-- ============================================================================
local gameState = "menu"   -- "menu"|"playing"|"win"
local currentLevel = 1
local cups = {}
local selectedCup = nil
local moveCount = 0
local history = {}
local gameTime = 0

-- UI 引用
---@type any
local uiRoot_ = nil
---@type any
local gameArea_ = nil

-- 音效
local sndPour_ = nil
local sndComplete_ = nil
local sndClick_ = nil
local soundNode_ = nil

-- ============================================================================
-- 工具
-- ============================================================================
local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local c = {}
    for k,v in pairs(t) do c[k] = deepCopy(v) end
    return c
end

local function getTopColor(cup)
    if #cup == 0 then return 0 end
    return cup[#cup]
end

local function getTopCount(cup)
    if #cup == 0 then return 0 end
    local color = cup[#cup]
    local n = 0
    for i = #cup, 1, -1 do
        if cup[i] == color then n = n + 1 else break end
    end
    return n
end

local function canPour(fi, ti)
    if fi == ti then return false end
    local f, t = cups[fi], cups[ti]
    if #f == 0 then return false end
    if #t >= CONFIG.CUP_CAPACITY then return false end
    if #t == 0 then return true end
    return getTopColor(f) == getTopColor(t)
end

local function calcPourCount(fi, ti)
    local f, t = cups[fi], cups[ti]
    return math.min(getTopCount(f), CONFIG.CUP_CAPACITY - #t)
end

local function executePour(fi, ti)
    local count = calcPourCount(fi, ti)
    if count <= 0 then return 0 end
    local color = getTopColor(cups[fi])
    table.insert(history, { from=fi, to=ti, count=count, color=color })
    for _ = 1, count do
        table.remove(cups[fi])
        table.insert(cups[ti], color)
    end
    moveCount = moveCount + 1
    return count
end

local function undoMove()
    if #history == 0 then return end
    local last = table.remove(history)
    for _ = 1, last.count do
        table.remove(cups[last.to])
        table.insert(cups[last.from], last.color)
    end
    moveCount = math.max(0, moveCount - 1)
    selectedCup = nil
    UpdateMoveLabel()
end

local function checkWin()
    for _, cup in ipairs(cups) do
        if #cup > 0 then
            if #cup ~= CONFIG.CUP_CAPACITY then return false end
            local c = cup[1]
            for j = 2, #cup do
                if cup[j] ~= c then return false end
            end
        end
    end
    return true
end

-- ============================================================================
-- 音效
-- ============================================================================
function InitAudio()
    local scene = Scene()
    soundNode_ = scene:CreateChild("SoundNode")
    sndPour_     = cache:GetResource("Sound", "audio/sfx/pour_water.ogg")
    sndComplete_ = cache:GetResource("Sound", "audio/sfx/level_complete.ogg")
    sndClick_    = cache:GetResource("Sound", "audio/sfx/cyber_click.ogg")
    print("Audio ready")
end

function PlaySound(snd)
    if snd and soundNode_ then
        local src = soundNode_:CreateComponent("SoundSource")
        src.soundType = "Effect"
        src.gain = 0.7
        src.autoRemoveMode = REMOVE_COMPONENT
        src:Play(snd)
    end
end

-- ============================================================================
-- 自定义杯子 Widget（赛博风格）
-- ============================================================================
local CupWidget = UI.Widget:Extend("CupWidget")

function CupWidget:Init(props)
    props = props or {}
    props.width  = props.width  or (CONFIG.CUP_WIDTH + 14)
    props.height = props.height or (CONFIG.CUP_HEIGHT + 32)
    props.pointerEvents = "auto"
    UI.Widget.Init(self, props)
    self.cupIndex_ = props.cupIndex or 1
    self.hovered_  = false
end

function CupWidget:Render(nvg)
    local l = self:GetAbsoluteLayout()
    local idx = self.cupIndex_
    if idx < 1 or idx > #cups then return end

    local cup        = cups[idx]
    local isSelected = (selectedCup == idx)
    local isHover    = self.hovered_

    local topW   = CONFIG.CUP_TOP_W
    local botW   = CONFIG.CUP_BOT_W
    local cupH   = CONFIG.CUP_HEIGHT
    local liftY  = isSelected and CONFIG.SELECTED_LIFT or 0

    local cx       = l.x + l.w / 2
    local baseY    = l.y + l.h - 6 + liftY
    local cupTop   = baseY - cupH
    local cupBot   = baseY

    local function xLeft(y)
        local t = (cupBot - y) / cupH
        return cx - (botW / 2 + (topW - botW) / 2 * t)
    end
    local function xRight(y)
        local t = (cupBot - y) / cupH
        return cx + (botW / 2 + (topW - botW) / 2 * t)
    end

    -- 绘制液体层
    local layerH = (cupH - 6) / CONFIG.CUP_CAPACITY

    -- 裁剪到杯子内部
    nvgSave(nvg)
    nvgBeginPath(nvg)
    -- 梯形裁剪路径
    local innerOffX = 1.5
    nvgMoveTo(nvg, xLeft(cupTop) + innerOffX, cupTop + 2)
    nvgLineTo(nvg, xRight(cupTop) - innerOffX, cupTop + 2)
    nvgLineTo(nvg, xRight(cupBot) - innerOffX, cupBot)
    nvgLineTo(nvg, xLeft(cupBot) + innerOffX, cupBot)
    nvgClosePath(nvg)
    nvgScissor(nvg, l.x, cupTop, l.w, cupH + 4)

    for i = 1, #cup do
        local c = COLORS[cup[i]]
        if c then
            local layerBot = cupBot - (i - 1) * layerH
            local layerTop2 = layerBot - layerH

            local lBot = xLeft(layerBot)
            local rBot = xRight(layerBot)
            local lTop2 = xLeft(layerTop2)
            local rTop2 = xRight(layerTop2)

            -- 液体渐变（亮到暗）
            local grad = nvgLinearGradient(nvg, cx, layerTop2, cx, layerBot,
                nvgRGBA(math.min(255,c[1]+50), math.min(255,c[2]+50), math.min(255,c[3]+50), 235),
                nvgRGBA(math.max(0,c[1]-30),  math.max(0,c[2]-30),  math.max(0,c[3]-30),  245))

            nvgBeginPath(nvg)
            if i == #cup then
                -- 顶层加波纹
                local waveY = layerTop2 + 2
                nvgMoveTo(nvg, lTop2, waveY)
                local steps = 10
                for s = 0, steps do
                    local frac = s / steps
                    local wx = lTop2 + (rTop2 - lTop2) * frac
                    local wy = waveY + math.sin(gameTime * CONFIG.WAVE_SPEED + frac * math.pi * 2) * CONFIG.WAVE_AMP
                    nvgLineTo(nvg, wx, wy)
                end
            else
                nvgMoveTo(nvg, lTop2, layerTop2)
                nvgLineTo(nvg, rTop2, layerTop2)
            end
            nvgLineTo(nvg, rBot, layerBot)
            nvgLineTo(nvg, lBot, layerBot)
            nvgClosePath(nvg)
            nvgFillPaint(nvg, grad)
            nvgFill(nvg)

            -- 液面高光条
            nvgBeginPath(nvg)
            local hw = (rTop2 - lTop2) * 0.13
            nvgRoundedRect(nvg, lTop2 + 3, layerTop2 + 2, hw, layerH - 4, 2)
            nvgFillColor(nvg, nvgRGBA(255,255,255,35))
            nvgFill(nvg)
        end
    end
    nvgRestore(nvg)

    -- 杯子轮廓（霓虹描边）
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, xLeft(cupTop), cupTop)
    nvgLineTo(nvg, xRight(cupTop), cupTop)
    nvgLineTo(nvg, xRight(cupBot), cupBot)
    nvgLineTo(nvg, xLeft(cupBot), cupBot)
    nvgClosePath(nvg)

    if isSelected then
        -- 选中：霓虹青发光
        nvgStrokeColor(nvg, nvgRGBA(0, 255, 255, 255))
        nvgStrokeWidth(nvg, 2.0)
        nvgStroke(nvg)
        -- 外发光
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, xLeft(cupTop)-3, cupTop-3)
        nvgLineTo(nvg, xRight(cupTop)+3, cupTop-3)
        nvgLineTo(nvg, xRight(cupBot)+3, cupBot+3)
        nvgLineTo(nvg, xLeft(cupBot)-3, cupBot+3)
        nvgClosePath(nvg)
        nvgStrokeColor(nvg, nvgRGBA(0,255,255,60))
        nvgStrokeWidth(nvg, 5.0)
        nvgStroke(nvg)
        nvgBeginPath(nvg)
        nvgMoveTo(nvg, xLeft(cupTop)-6, cupTop-6)
        nvgLineTo(nvg, xRight(cupTop)+6, cupTop-6)
        nvgLineTo(nvg, xRight(cupBot)+6, cupBot+6)
        nvgLineTo(nvg, xLeft(cupBot)-6, cupBot+6)
        nvgClosePath(nvg)
        nvgStrokeColor(nvg, nvgRGBA(0,255,255,25))
        nvgStrokeWidth(nvg, 10.0)
        nvgStroke(nvg)
    elseif isHover then
        nvgStrokeColor(nvg, nvgRGBA(0, 200, 220, 160))
        nvgStrokeWidth(nvg, 1.5)
        nvgStroke(nvg)
    else
        nvgStrokeColor(nvg, nvgRGBA(80, 120, 150, 120))
        nvgStrokeWidth(nvg, 1.2)
        nvgStroke(nvg)
    end

    -- 杯口顶边
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, xLeft(cupTop) - 2, cupTop)
    nvgLineTo(nvg, xRight(cupTop) + 2, cupTop)
    local borderClr = isSelected and nvgRGBA(0,255,255,200) or nvgRGBA(60,110,140,130)
    nvgStrokeColor(nvg, borderClr)
    nvgStrokeWidth(nvg, isSelected and 2.5 or 1.5)
    nvgStroke(nvg)

    -- 玻璃左侧高光
    nvgBeginPath(nvg)
    nvgMoveTo(nvg, xLeft(cupTop)+3, cupTop+6)
    nvgLineTo(nvg, xLeft(cupBot)+3, cupBot-6)
    nvgStrokeColor(nvg, nvgRGBA(180,220,255,25))
    nvgStrokeWidth(nvg, 1.0)
    nvgStroke(nvg)

    -- 选中时顶部光晕
    if isSelected then
        nvgBeginPath(nvg)
        nvgEllipse(nvg, cx, cupTop, topW * 0.6, 6)
        local glow = nvgRadialGradient(nvg, cx, cupTop, 0, topW * 0.6,
            nvgRGBA(0,255,255,90), nvgRGBA(0,255,255,0))
        nvgFillPaint(nvg, glow)
        nvgFill(nvg)
    end
end

function CupWidget:OnClick(event)
    if gameState ~= "playing" then return end
    local idx = self.cupIndex_

    if selectedCup == nil then
        if #cups[idx] > 0 then
            selectedCup = idx
            PlaySound(sndClick_)
        end
    elseif selectedCup == idx then
        selectedCup = nil
        PlaySound(sndClick_)
    else
        if canPour(selectedCup, idx) then
            local count = executePour(selectedCup, idx)
            if count > 0 then
                PlaySound(sndPour_)
                selectedCup = nil
                UpdateMoveLabel()
                if checkWin() then
                    gameState = "win"
                    PlaySound(sndComplete_)
                    ShowWinDialog()
                end
            end
        else
            if #cups[idx] > 0 then
                selectedCup = idx
                PlaySound(sndClick_)
            else
                selectedCup = nil
            end
        end
    end
end

function CupWidget:OnPointerEnter(event)
    self.hovered_ = true
end

function CupWidget:OnPointerLeave(event)
    self.hovered_ = false
end

-- ============================================================================
-- 关卡管理
-- ============================================================================
function LoadLevel(level)
    if level > #LEVELS then level = 1 end
    currentLevel = level
    cups = deepCopy(LEVELS[currentLevel].cups)
    selectedCup = nil
    moveCount = 0
    history = {}
    gameState = "playing"
    RefreshGameArea()
    UpdateMoveLabel()
    print("Level " .. currentLevel .. " loaded")
end

-- ============================================================================
-- UI 辅助
-- ============================================================================
function UpdateMoveLabel()
    if not uiRoot_ then return end
    local ml = uiRoot_:FindById("moveLabel")
    if ml then ml:SetText(tostring(moveCount)) end
    local ll = uiRoot_:FindById("levelLabel")
    if ll then ll:SetText("第 " .. currentLevel .. " 关") end
end

function RefreshGameArea()
    if not gameArea_ then return end
    gameArea_:ClearChildren()
    for i = 1, #cups do
        gameArea_:AddChild(CupWidget { cupIndex = i })
    end
end

-- ============================================================================
-- 通关弹窗
-- ============================================================================
function ShowWinDialog()
    local old = uiRoot_:FindById("winDialog")
    if old then old:Destroy() end

    local btnChildren = {}
    if currentLevel < #LEVELS then
        table.insert(btnChildren, NeonButton {
            text = "下一关",
            width = 130,
            height = 42,
            fontSize = 15,
            color = "cyan",
            onClick = function()
                local d = uiRoot_:FindById("winDialog")
                if d then d:Destroy() end
                LoadLevel(currentLevel + 1)
            end,
        })
    end
    table.insert(btnChildren, NeonButton {
        text = "重玩",
        width = 90,
        height = 42,
        fontSize = 14,
        color = "pink",
        onClick = function()
            local d = uiRoot_:FindById("winDialog")
            if d then d:Destroy() end
            LoadLevel(currentLevel)
        end,
    })

    local dialog = CyberDialog({
        id = "winDialog",
        title = "关卡完成",
        content = "用了 " .. moveCount .. " 步",
        onClose = function()
            local d = uiRoot_:FindById("winDialog")
            if d then d:Destroy() end
        end,
        children = {
            UI.Panel {
                flexDirection = "row",
                gap = 12,
                marginTop = 8,
                justifyContent = "center",
                children = btnChildren,
            }
        }
    })
    uiRoot_:AddChild(dialog)
end

-- ============================================================================
-- 主菜单
-- ============================================================================
function ShowMenu()
    gameState = "menu"
    local old = uiRoot_:FindById("menuOverlay")
    if old then old:Destroy() end

    -- 关卡选择按钮网格
    local levelGridRows = {}
    local cols = 4
    local totalLevels = #LEVELS
    local rowChildren = nil
    for i = 1, totalLevels do
        if (i - 1) % cols == 0 then
            rowChildren = {}
            table.insert(levelGridRows, UI.Panel {
                flexDirection = "row",
                gap = 8,
                justifyContent = "center",
                children = rowChildren,
            })
        end
        local lvl = i
        table.insert(rowChildren, UI.Panel {
            width = 48,
            height = 42,
            borderRadius = 8,
            backgroundColor = { 20, 16, 34, 220 },
            borderWidth = 1,
            borderColor = { 0, 255, 255, 50 },
            justifyContent = "center",
            alignItems = "center",
            pointerEvents = "auto",
            transition = "scale 0.1s easeOut",
            onPointerDown = function(event, widget)
                widget.scale = 0.9
            end,
            onPointerUp = function(event, widget)
                widget.scale = 1.0
                local old2 = uiRoot_:FindById("menuOverlay")
                if old2 then old2:Destroy() end
                LoadLevel(lvl)
            end,
            children = {
                UI.Label {
                    text = tostring(lvl),
                    fontSize = 14,
                    fontColor = Theme.colors.neonCyan,
                },
            }
        })
    end

    local overlay = UI.Panel {
        id = "menuOverlay",
        position = "absolute",
        top = 0, left = 0, right = 0, bottom = 0,
        backgroundColor = { 0, 0, 0, 180 },
        justifyContent = "center",
        alignItems = "center",
        pointerEvents = "auto",
        zIndex = 50,
        children = {
            UI.Panel {
                width = "88%",
                maxWidth = 340,
                padding = 28,
                gap = 16,
                backgroundColor = { 20, 14, 32, 248 },
                borderRadius = Theme.radius.lg,
                borderWidth = 1,
                borderColor = { 0, 255, 255, 50 },
                boxShadow = {
                    { x=0, y=0, blur=30, spread=2, color={0,255,255,30} },
                    { x=0, y=8, blur=24, spread=0, color={0,0,0,120} },
                },
                alignItems = "center",
                children = {
                    -- 顶部装饰线
                    UI.Panel {
                        width = "100%",
                        height = 2,
                        backgroundGradient = {
                            type = "linear",
                            direction = "to-right",
                            from = { 0, 255, 255, 200 },
                            to = { 147, 51, 234, 200 },
                        },
                        borderRadius = 1,
                    },
                    UI.Label {
                        text = "赛博之都·倒水",
                        fontSize = Theme.fontSize.xxl,
                        fontColor = Theme.colors.neonCyan,
                    },
                    UI.Label {
                        text = "将同色液体归入同一杯",
                        fontSize = Theme.fontSize.sm,
                        fontColor = Theme.colors.textSecondary,
                    },
                    -- 开始按钮
                    NeonButton {
                        text = "开始游戏",
                        width = 170,
                        height = 46,
                        fontSize = Theme.fontSize.lg,
                        color = "cyan",
                        onClick = function()
                            local old2 = uiRoot_:FindById("menuOverlay")
                            if old2 then old2:Destroy() end
                            LoadLevel(1)
                        end,
                    },
                    -- 分隔线
                    UI.Panel {
                        width = "100%",
                        height = 1,
                        backgroundColor = { 255, 255, 255, 12 },
                    },
                    -- 关卡选择
                    UI.Label {
                        text = "选择关卡",
                        fontSize = Theme.fontSize.xs,
                        fontColor = Theme.colors.textSecondary,
                    },
                    UI.Panel {
                        gap = 8,
                        alignItems = "center",
                        children = levelGridRows,
                    },
                }
            }
        }
    }
    uiRoot_:AddChild(overlay)
end

-- ============================================================================
-- 整体 UI 布局
-- ============================================================================
function CreateUI()
    -- 游戏区域
    gameArea_ = UI.Panel {
        id = "gameArea",
        width = "100%",
        flexGrow = 1,
        flexDirection = "row",
        flexWrap = "wrap",
        justifyContent = "center",
        alignItems = "center",
        gap = 12,
        paddingLeft = 12,
        paddingRight = 12,
        pointerEvents = "box-none",
    }

    -- HUD 卡片
    local hudCard = HoloCard {
        padding = Theme.spacing.md,
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                alignItems = "center",
                children = {
                    -- 关卡信息
                    UI.Panel {
                        gap = 2,
                        children = {
                            UI.Label {
                                text = "关卡",
                                fontSize = Theme.fontSize.xs,
                                fontColor = Theme.colors.textSecondary,
                            },
                            UI.Label {
                                id = "levelLabel",
                                text = "第 1 关",
                                fontSize = Theme.fontSize.lg,
                                fontColor = Theme.colors.neonCyan,
                            },
                        }
                    },
                    -- 步数信息
                    UI.Panel {
                        alignItems = "center",
                        gap = 2,
                        children = {
                            UI.Label {
                                text = "步数",
                                fontSize = Theme.fontSize.xs,
                                fontColor = Theme.colors.textSecondary,
                            },
                            UI.Label {
                                id = "moveLabel",
                                text = "0",
                                fontSize = Theme.fontSize.xl,
                                fontColor = Theme.colors.warning,
                            },
                        }
                    },
                    -- 操作按钮组
                    UI.Panel {
                        flexDirection = "row",
                        gap = 8,
                        alignItems = "center",
                        children = {
                            NeonButton {
                                text = "撤",
                                width = 38,
                                height = 32,
                                fontSize = 13,
                                color = "pink",
                                onClick = function()
                                    if gameState == "playing" then
                                        undoMove()
                                        RefreshGameArea()
                                    end
                                end,
                            },
                            NeonButton {
                                text = "重",
                                width = 38,
                                height = 32,
                                fontSize = 13,
                                color = "cyan",
                                onClick = function()
                                    if gameState == "playing" or gameState == "win" then
                                        LoadLevel(currentLevel)
                                    end
                                end,
                            },
                            NeonButton {
                                text = "≡",
                                width = 38,
                                height = 32,
                                fontSize = 16,
                                color = "cyan",
                                onClick = function()
                                    ShowMenu()
                                end,
                            },
                        }
                    },
                }
            }
        }
    }

    uiRoot_ = UI.Panel {
        id = "root",
        width = "100%",
        height = "100%",
        flexDirection = "column",
        gap = Theme.spacing.md,
        paddingLeft = Theme.spacing.md,
        paddingRight = Theme.spacing.md,
        paddingTop = Theme.spacing.md,
        paddingBottom = Theme.spacing.md,
        children = {
            CyberBg {},
            hudCard,
            gameArea_,
        }
    }

    UI.SetRoot(uiRoot_)
end

-- ============================================================================
-- 生命周期
-- ============================================================================
function Start()
    graphics.windowTitle = "赛博之都·倒水闯关"

    InitAudio()

    UI.Init({
        fonts = {
            { family = "sans", weights = { normal = "Fonts/MiSans-Regular.ttf" } }
        },
        scale = UI.Scale.DEFAULT,
    })

    CreateUI()
    ShowMenu()

    SubscribeToEvent("Update", "HandleUpdate")
    SubscribeToEvent("KeyDown", "HandleKeyDown")

    print("=== 赛博之都·倒水闯关 启动 ===")
end

function Stop()
    UI.Shutdown()
end

---@param eventType string
---@param eventData UpdateEventData
function HandleUpdate(eventType, eventData)
    gameTime = gameTime + eventData["TimeStep"]:GetFloat()
end

---@param eventType string
---@param eventData KeyDownEventData
function HandleKeyDown(eventType, eventData)
    local key = eventData["Key"]:GetInt()
    if key == KEY_ESCAPE then
        if gameState == "playing" then ShowMenu() end
    elseif key == KEY_Z then
        if gameState == "playing" then
            undoMove()
            RefreshGameArea()
        end
    elseif key == KEY_R then
        if gameState == "playing" then LoadLevel(currentLevel) end
    end
end
