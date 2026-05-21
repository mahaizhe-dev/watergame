local MechanicsCatalog = {
    vessels = {
        classic = {
            id = "classic",
            summary = "Standard vessel with normal sort rules.",
            tutorialWeight = 0,
        },
        locked = {
            id = "locked",
            summary = "Requires an unlock condition before pouring.",
            tutorialWeight = 2,
        },
        oneWay = {
            id = "one_way",
            summary = "Can pour out only in one direction.",
            tutorialWeight = 3,
        },
        cracked = {
            id = "cracked",
            summary = "Punishes overuse or specific liquid types.",
            tutorialWeight = 4,
        },
    },

    liquids = {
        normal = {
            id = "normal",
            summary = "Classic liquid segment.",
            tutorialWeight = 0,
        },
        heated = {
            id = "heated",
            summary = "Changes behavior when paired with temperature triggers.",
            tutorialWeight = 3,
        },
        sludge = {
            id = "sludge",
            summary = "Sticky layer that blocks free movement.",
            tutorialWeight = 4,
        },
        catalyst = {
            id = "catalyst",
            summary = "Activates devices or transforms adjacent rules.",
            tutorialWeight = 5,
        },
    },

    boardRules = {
        standard = {
            id = "standard",
            summary = "No board modifiers.",
            tutorialWeight = 0,
        },
        conveyor = {
            id = "conveyor",
            summary = "Repositions vessels after a move or phase.",
            tutorialWeight = 4,
        },
        elevator = {
            id = "elevator",
            summary = "Changes active lanes and move access.",
            tutorialWeight = 4,
        },
        contamination = {
            id = "contamination",
            summary = "Adds cleanup pressure to the puzzle.",
            tutorialWeight = 5,
        },
    },
}

return MechanicsCatalog
