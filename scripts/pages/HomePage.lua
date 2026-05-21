-- ============================================================================
-- 首页 - 赛博之都主菜单
-- ============================================================================

local UI = require("urhox-libs/UI")
local Theme = require("ui.theme")
local NeonButton = require("ui.NeonButton")
local HoloCard = require("ui.HoloCard")
local DataPanel = require("ui.DataPanel")
local GlowProgress = require("ui.GlowProgress")

local HomePage = {}

--- 创建首页内容
--- @param ctx table { onStartGame, onSettings }
function HomePage.Create(ctx)
    ctx = ctx or {}

    -- 赛博标题
    local title = UI.Label {
        text = "赛 博 之 都",
        fontSize = Theme.fontSize.hero,
        fontColor = Theme.colors.neonCyan,
        marginTop = Theme.spacing.xxl,
    }

    -- 副标题
    local subtitle = UI.Label {
        text = "CYBER  CHONGQING",
        fontSize = Theme.fontSize.sm,
        fontColor = Theme.colors.textSecondary,
        marginTop = Theme.spacing.xs,
    }

    -- 数据卡片：金币 + 等级
    local statsCard = HoloCard {
        padding = Theme.spacing.lg,
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-around",
                children = {
                    DataPanel { label = "信用点", value = "1,280", valueColor = Theme.colors.warning },
                    DataPanel { label = "等级", value = "Lv.5", valueColor = Theme.colors.neonCyan },
                    DataPanel { label = "星星", value = "18/36", valueColor = Theme.colors.success },
                }
            },
        }
    }

    -- 进度条：总进度
    local progressSection = UI.Panel {
        width = "100%",
        gap = Theme.spacing.sm,
        paddingLeft = Theme.spacing.lg,
        paddingRight = Theme.spacing.lg,
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                children = {
                    UI.Label {
                        text = "探索进度",
                        fontSize = Theme.fontSize.xs,
                        fontColor = Theme.colors.textSecondary,
                    },
                    UI.Label {
                        text = "50%",
                        fontSize = Theme.fontSize.xs,
                        fontColor = Theme.colors.neonCyan,
                    },
                }
            },
            GlowProgress { progress = 0.5, height = 8 },
        }
    }

    -- 主按钮
    local startBtn = NeonButton {
        text = "进 入 城 市",
        width = 200,
        height = 50,
        fontSize = Theme.fontSize.lg,
        color = "cyan",
        onClick = function(self)
            if ctx.onStartGame then ctx.onStartGame() end
        end,
    }

    -- 今日挑战卡片
    local challengeCard = HoloCard {
        padding = Theme.spacing.md,
        children = {
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                justifyContent = "space-between",
                alignItems = "center",
                children = {
                    UI.Panel {
                        gap = 2,
                        children = {
                            UI.Label {
                                text = "每日挑战",
                                fontSize = Theme.fontSize.base,
                                fontColor = Theme.colors.textPrimary,
                            },
                            UI.Label {
                                text = "完成3关获得额外奖励",
                                fontSize = Theme.fontSize.xs,
                                fontColor = Theme.colors.textSecondary,
                            },
                        }
                    },
                    NeonButton {
                        text = "挑战",
                        width = 70,
                        height = 32,
                        fontSize = Theme.fontSize.sm,
                        color = "pink",
                        onClick = function(self)
                            if ctx.onStartGame then ctx.onStartGame() end
                        end,
                    },
                }
            },
        }
    }

    return UI.Panel {
        width = "100%",
        flexGrow = 1,
        alignItems = "center",
        gap = Theme.spacing.lg,
        paddingLeft = Theme.spacing.lg,
        paddingRight = Theme.spacing.lg,
        paddingBottom = Theme.spacing.lg,
        children = {
            title,
            subtitle,
            UI.Panel { height = Theme.spacing.md },  -- spacer
            statsCard,
            progressSection,
            UI.Panel { flexGrow = 1 },  -- spacer
            startBtn,
            UI.Panel { height = Theme.spacing.sm },
            challengeCard,
        }
    }
end

return HomePage
