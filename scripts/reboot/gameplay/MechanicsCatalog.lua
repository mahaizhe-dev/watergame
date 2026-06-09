local MechanicsCatalog = {
    vessels = {
        classic = {
            id = "classic",
            summary = "标准猫咪瓶，使用经典倒水规则。",
            tutorialWeight = 0,
        },
        locked = {
            id = "locked",
            summary = "锁瓶，需要先完成指定数量的整瓶才会打开。",
            tutorialWeight = 2,
        },
        oneWayOut = {
            id = "one_way_out",
            summary = "箭头瓶只能倒出，不能作为落点。",
            tutorialWeight = 3,
        },
        oneWayIn = {
            id = "one_way_in",
            summary = "箭头瓶只能接水，不能作为起始瓶。",
            tutorialWeight = 3,
        },
        cracked = {
            id = "cracked",
            summary = "裂纹瓶作为起始瓶的次数有限，用完就会报废。",
            tutorialWeight = 4,
        },
    },

    liquids = {
        normal = {
            id = "normal",
            summary = "普通液体层，当前战役只使用标准液体。",
            tutorialWeight = 0,
        },
    },

    boardRules = {
        standard = {
            id = "standard",
            summary = "无棋盘机关，纯经典倒水布局。",
            tutorialWeight = 0,
        },
        conveyor = {
            id = "conveyor",
            summary = "传送带会在每步后移动整排瓶子的位置。",
            tutorialWeight = 4,
        },
        elevator = {
            id = "elevator",
            summary = "升降梯会切换当前可作为起始瓶的轨道。",
            tutorialWeight = 4,
        },
    },
}

return MechanicsCatalog
