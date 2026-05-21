-- ============================================================================
-- 底部导航栏 - 赛博风格
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")

--- 创建底部导航栏
--- @param props table { items = { { label, icon } }, activeIndex, onChange }
local function NavBar(props)
    props = props or {}
    local items = props.items or {}
    local activeIndex = props.activeIndex or 1
    local onChange = props.onChange

    local tabChildren = {}
    for i, item in ipairs(items) do
        local isActive = (i == activeIndex)

        local tabItems = {}

        -- 图标文字（用 emoji 或符号代替真图标）
        table.insert(tabItems, UI.Label {
            text = item.icon or "●",
            fontSize = 18,
            fontColor = isActive and Theme.colors.neonCyan or Theme.colors.textSecondary,
            transition = "fontColor 0.2s easeOut",
        })

        -- 标签
        table.insert(tabItems, UI.Label {
            text = item.label or "",
            fontSize = Theme.fontSize.xs,
            fontColor = isActive and Theme.colors.neonCyan or Theme.colors.textMuted,
            transition = "fontColor 0.2s easeOut",
        })

        -- 底部小光点指示器
        if isActive then
            table.insert(tabItems, UI.Panel {
                width = 16,
                height = 2,
                borderRadius = 1,
                backgroundColor = Theme.colors.neonCyan,
                boxShadow = {
                    { x = 0, y = 0, blur = 6, spread = 1, color = { 0, 255, 255, 100 } },
                },
                marginTop = 2,
            })
        else
            table.insert(tabItems, UI.Panel {
                width = 16,
                height = 2,
                marginTop = 2,
            })
        end

        local idx = i
        table.insert(tabChildren, UI.Panel {
            flexGrow = 1,
            alignItems = "center",
            justifyContent = "center",
            gap = 2,
            paddingTop = 6,
            paddingBottom = 4,
            pointerEvents = "auto",
            onPointerDown = function(event, widget)
                if onChange then
                    onChange(idx)
                end
            end,
            children = tabItems,
        })
    end

    return UI.Panel {
        id = props.id or "navbar",
        width = "100%",
        height = 66,
        flexDirection = "row",
        backgroundColor = Theme.colors.bgNavbar,
        borderTopWidth = 1,
        borderTopColor = { 0, 255, 255, 30 },
        children = tabChildren,
    }
end

return NavBar
