-- ============================================================================
-- 赛博弹窗 - 半透明遮罩 + 霓虹装饰线 + 入场动画
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")

--- 创建赛博弹窗
--- @param props table { title, content, children(按钮组), onClose }
local function CyberDialog(props)
    props = props or {}

    local contentChildren = {}

    -- 顶部霓虹装饰线
    table.insert(contentChildren, UI.Panel {
        width = "100%",
        height = 2,
        backgroundGradient = {
            type = "linear",
            direction = "to-right",
            from = { 0, 255, 255, 180 },
            to = { 147, 51, 234, 180 },
        },
        borderRadius = 1,
        marginBottom = Theme.spacing.md,
    })

    -- 标题
    if props.title then
        table.insert(contentChildren, UI.Label {
            text = props.title,
            fontSize = Theme.fontSize.xl,
            fontColor = Theme.colors.textPrimary,
        })
    end

    -- 内容文本
    if props.content then
        table.insert(contentChildren, UI.Label {
            text = props.content,
            fontSize = Theme.fontSize.base,
            fontColor = Theme.colors.textSecondary,
            marginTop = Theme.spacing.sm,
        })
    end

    -- 子元素（按钮组等）
    if props.children then
        for _, child in ipairs(props.children) do
            table.insert(contentChildren, child)
        end
    end

    -- 弹窗卡片
    local card = UI.Panel {
        width = "85%",
        maxWidth = 320,
        padding = Theme.spacing.xl,
        gap = Theme.spacing.md,
        backgroundColor = Theme.colors.bgCardSolid,
        borderRadius = Theme.radius.lg,
        borderWidth = 1,
        borderColor = { 0, 255, 255, 40 },
        alignItems = "center",
        boxShadow = {
            { x = 0, y = 0, blur = 30, spread = 2, color = { 0, 255, 255, 30 } },
            { x = 0, y = 8, blur = 24, spread = 0, color = { 0, 0, 0, 100 } },
        },
        -- 入场动画
        opacity = 0,
        scale = 0.85,
        transition = "opacity 0.3s easeOut, scale 0.3s easeOutBack",
        children = contentChildren,
    }

    -- 一帧后触发动画
    local function triggerAnim()
        card.opacity = 1
        card.scale = 1.0
    end

    local overlay = UI.Panel {
        id = props.id or "cyberDialog",
        position = "absolute",
        top = 0, left = 0, right = 0, bottom = 0,
        backgroundColor = Theme.colors.bgOverlay,
        justifyContent = "center",
        alignItems = "center",
        pointerEvents = "auto",
        zIndex = 100,
        opacity = 0,
        transition = "opacity 0.25s easeOut",
        onPointerDown = function(event, widget)
            -- 点击遮罩关闭
            if props.onClose then
                props.onClose()
            end
        end,
        children = { card },
    }

    -- 阻止卡片内点击冒泡到遮罩
    card.pointerEvents = "auto"
    card.onPointerDown = function(event, widget)
        -- 不做任何事，只阻止冒泡
    end

    -- 触发渐入
    overlay.opacity = 1
    triggerAnim()

    return overlay
end

return CyberDialog
