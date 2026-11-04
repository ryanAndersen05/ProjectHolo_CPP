local StateMachineCommon = require("assets.animation.statemachine")
local states = {}

states.parameters = {
    ["hInput"] = StateMachineCommon.EParameterType.Int,
    ["vInput"] = StateMachineCommon.EParameterType.Int,
    ["vVelocity"] = StateMachineCommon.EParameterType.Float,
    ["inAir"] = StateMachineCommon.EParameterType.Bool,
    ["jump"] = StateMachineCommon.EParameterType.Trigger,
    ["doubleForward"] = StateMachineCommon.EParameterType.Trigger,
    ["doubleBack"] = StateMachineCommon.EParameterType.Trigger,
    ["button"] = StateMachineCommon.EParameterType.Trigger,
    ["light"] = StateMachineCommon.EParameterType.Trigger,
    ["lightRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["lightHeld"] = StateMachineCommon.EParameterType.Bool,
    ["medium"] = StateMachineCommon.EParameterType.Trigger,
    ["mediumRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["mediumHeld"] = StateMachineCommon.EParameterType.Bool,
    ["heavy"] = StateMachineCommon.EParameterType.Trigger,
    ["heavyRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["heavyHeld"] = StateMachineCommon.EParameterType.Bool,
    ["special"] = StateMachineCommon.EParameterType.Trigger,
    ["specialRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["specialHeld"] = StateMachineCommon.EParameterType.Bool,
    ["grab"] = StateMachineCommon.EParameterType.Trigger,
    ["grabId"] = StateMachineCommon.EParameterType.Int,
    ["blockBurst"] = StateMachineCommon.EParameterType.Bool,
    ["burst"] = StateMachineCommon.EParameterType.Trigger,
    ["qcf"] = StateMachineCommon.EParameterType.Trigger,
    ["qcb"] = StateMachineCommon.EParameterType.Trigger,
    ["doubleQcf"] = StateMachineCommon.EParameterType.Trigger,
    ["doubleDown"] = StateMachineCommon.EParameterType.Trigger,
    ["exBars"] = StateMachineCommon.EParameterType.Int,
    ["hitConfirm"] = StateMachineCommon.EParameterType.Trigger,
    ["wasHit"] = StateMachineCommon.EParameterType.Trigger,
    ["hitStun"] = StateMachineCommon.EParameterType.Bool,
    ["isDead"] = StateMachineCommon.EParameterType.Bool,
    ["hitType"] = StateMachineCommon.EParameterType.Int,
    ["win"] = StateMachineCommon.EParameterType.Trigger,
    ["canHoldTrident"] = StateMachineCommon.EParameterType.Bool,
}

states.defaultState = "gura_default"
states.spriteAsset = "gura_atlas"

states.any_state = {
    transitions = {
        {
            state = "gura_washit",
            conditions = {
                {
                    parameter = "wasHit"
                },
            }
        },
        {
            state = "gura_burst",
            conditions = {
                {
                    parameter = "burst"
                },
                {
                    parameter = "blockBurst",
                    value = false
                },
            }
        },
    },
    tick = function(self, actor, frame)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end
}

-- Gura_Default: choose the next animation.
states.gura_default = {
    transitions = {
        {
            state = "gura_airrise",
            conditions = {
                {
                    parameter = "inAir",
                    value = true
                },
            }
        },
        {
            state = "gura_idle",
            conditions = {}
        },
    },
    tick = function(self, actor, frame)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
    end
}

-- Gura_QCBRollEXTrans: choose the next animation.
states.gura_rollexcheck = {
    transitions = {
        {
            state = "gura_rollex",
            conditions = {
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.gura_rollexcheck, states.parameters)
    end
}

-- Gura_StandingAttack: choose the next animation.
states.gura_standingattack = {
    transitions = {
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
        {
            state = "gura_rollexcheck",
            conditions = {
                {
                    parameter = "qcb"
                },
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_rolllight",
            conditions = {
                {
                    parameter = "qcb"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {
                {
                    parameter = "qcb"
                },
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_grabstart",
            conditions = {
                {
                    parameter = "grab"
                },
            }
        },
        {
            state = "gura_slight",
            conditions = {
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_smedium",
            conditions = {
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_sheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_sspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
            }
        },
        {
            state = "gura_slight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.gura_standingattack, states.parameters)
    end
}

-- Gura_AirAttack: choose the next animation.
states.gura_airattack = {
    transitions = {
        {
            state = "gura_alight",
            conditions = {
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_amedium",
            conditions = {
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_aheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_aspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
            }
        },
        {
            state = "gura_alight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.gura_airattack, states.parameters)
    end
}

-- Gura_CrouchAttack: choose the next animation.
states.gura_crouchattack = {
    transitions = {
        {
            state = "gura_grabstart",
            conditions = {
                {
                    parameter = "grab"
                },
            }
        },
        {
            state = "gura_clight",
            conditions = {
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_cmedium",
            conditions = {
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_cheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_sspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
            }
        },
        {
            state = "gura_cmedium",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.gura_crouchattack, states.parameters)
    end
}

-- Gura_Blocked: choose the next animation.
states.gura_blocked = {
    transitions = {
        {
            state = "gura_blocka",
            conditions = {
                {
                    parameter = "inAir",
                    value = true
                },
            }
        },
        {
            state = "gura_blockc",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_blocks",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.gura_blocked, states.parameters)
    end
}

-- Gura_WasHit: choose the next animation.
states.gura_washit = {
    transitions = {
        {
            state = "gura_grabbedstart",
            conditions = {
                {
                    parameter = "hitType",
                    conditionType = StateMachineCommon.EConditionType.Equal,
                    value = 3
                },
            }
        },
        {
            state = "gura_blocked",
            conditions = {
                {
                    parameter = "hitType",
                    conditionType = StateMachineCommon.EConditionType.Equal,
                    value = 2
                },
            }
        },
        {
            state = "gura_knockdownstart",
            conditions = {
                {
                    parameter = "isDead",
                    value = true
                },
                {
                    parameter = "inAir",
                    value = false
                },
                {
                    parameter = "vVelocity",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0.001
                },
            }
        },
        {
            state = "gura_knockdownstart",
            conditions = {
                {
                    parameter = "hitType",
                    conditionType = StateMachineCommon.EConditionType.Equal,
                    value = 4
                },
            }
        },
        {
            state = "gura_hitrise",
            conditions = {
                {
                    parameter = "inAir",
                    value = true
                },
            }
        },
        {
            state = "gura_hitrise",
            conditions = {
                {
                    parameter = "vVelocity",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_hitsstart",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.gura_washit, states.parameters)
    end
}

-- Gura_PushBlock: choose the next animation.
states.gura_pushblock = {
    transitions = {
        {
            state = "gura_pushblocka",
            conditions = {
                {
                    parameter = "inAir",
                    value = true
                },
            }
        },
        {
            state = "gura_pushblockc",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_pushblocks",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.gura_pushblock, states.parameters)
    end
}

-- Gura_SIdle / Gura_SIdle
states.gura_idle = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle02") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle03") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle04") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle05") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle06") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle07") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle08") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle09") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle00") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle01") end,
    },
    maxFrames = 51,
    transitions = {
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_walkfstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkbstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_win",
            conditions = {
                {
                    parameter = "win"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_idle02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SWalkF / Gura_SWalkF_Start
states.gura_walkfstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf00") end,
    },
    maxFrames = 4,
    transitions = {
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkbstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_walkf",
            minFrame = 5,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkf00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Walk)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
}

-- Gura_SWalkF / Gura_SWalkF
states.gura_walkf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf00") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf01") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf02") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf03") end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf04") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf05") end,
    },
    maxFrames = 37,
    transitions = {
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkbstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_walkfend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 1.0 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SWalkF / Gura_SWalkF_End
states.gura_walkfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf00") end,
    },
    maxFrames = 4,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 5,
            conditions = {}
        },
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkbstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SWalkB / Gura_SWalkB_Start
states.gura_walkbstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb00") end,
    },
    maxFrames = 3,
    transitions = {
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkfstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_walkb",
            minFrame = 4,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkb00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.WalkBack)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
}

-- Gura_SWalkB / Gura_SWalkB
states.gura_walkb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb05") end,
    },
    maxFrames = 31,
    transitions = {
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkfstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_walkbend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = -1.0 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkb00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.WalkBack)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
}

-- Gura_SWalkB / Gura_SWalkB_End
states.gura_walkbend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb00") end,
    },
    maxFrames = 4,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 5,
            conditions = {}
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkfstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SDashF / Gura_SDashF_Start
states.gura_dashfstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run00") end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "gura_walkbstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_dashf",
            minFrame = 7,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_run00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SDashF / Gura_SDashF
states.gura_dashf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run02") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run03") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run04") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run05") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run06") end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run07") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run08") end,
    },
    maxFrames = 33,
    transitions = {
        {
            state = "gura_crouchattack",
            conditions = {
                {
                    parameter = "button"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                },
            }
        },
        {
            state = "gura_walkbstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_dashfend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 1.0 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_run01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SDashF / Gura_SDashF_End
states.gura_dashfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_run09") end,
    },
    maxFrames = 11,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 12,
            conditions = {}
        },
        {
            state = "gura_walkbstart",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_run09")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SDashB / Gura_SDashB
states.gura_dashb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb01") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb02") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb01") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb03") end,
    },
    maxFrames = 18,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 19,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dashb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SStandToCrouch / Gura_SStandToCrouch
states.gura_stand2crouch = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_crouch00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_crouch01") end,
    },
    maxFrames = 5,
    transitions = {
        {
            state = "gura_crouch",
            minFrame = 6,
            conditions = {}
        },
        {
            state = "gura_crouchattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_crouch2stand",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = -1
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_crouch00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SJumpStart / Gura_SJumpStart
states.gura_jumpstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump00") end,
    },
    maxFrames = 3,
    transitions = {
        {
            state = "gura_airrise",
            minFrame = 4,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_jump00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_EndWin / Gura_Win
states.gura_win = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win04") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win05") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win06") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win07") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win08") end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("gura_win09") end,
    },
    maxFrames = 61,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_win00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AInAir / Gura_ARising
states.gura_airrise = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump00") end,
    },
    maxFrames = 4,
    transitions = {
        {
            state = "gura_idle",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
            }
        },
        {
            state = "gura_airdashf",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_airdashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_airjump",
            conditions = {
                {
                    parameter = "jump"
                },
            }
        },
        {
            state = "gura_airattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_airapex",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.0 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_jump00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AInAir / Gura_ARiseToFall
states.gura_airapex = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump01") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump03") end,
    },
    maxFrames = 10,
    transitions = {
        {
            state = "gura_idle",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
            }
        },
        {
            state = "gura_airdashf",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_airdashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_airjump",
            conditions = {
                {
                    parameter = "jump"
                },
            }
        },
        {
            state = "gura_airattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_airfall",
            minFrame = 11,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_jump01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AInAir / Gura_AFalling
states.gura_airfall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump04") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump05") end,
    },
    maxFrames = 13,
    transitions = {
        {
            state = "gura_idle",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
            }
        },
        {
            state = "gura_airdashf",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_airdashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_airjump",
            conditions = {
                {
                    parameter = "jump"
                },
            }
        },
        {
            state = "gura_airattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_jump04")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AJump / Gura_AJump
states.gura_airjump = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_jump00") end,
    },
    maxFrames = 3,
    transitions = {
        {
            state = "gura_airrise",
            minFrame = 4,
            conditions = {}
        },
        {
            state = "gura_airdashf",
            conditions = {
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_airdashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_airattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_jump00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_ADashF / Gura_ADashF
states.gura_airdashf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashf00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashf01") end,
    },
    maxFrames = 3,
    transitions = {
        {
            state = "gura_airdashfend",
            minFrame = 4,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dashf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_ADashF / Gura_ADashF_End
states.gura_airdashfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashf01") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashf02") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashf01") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashf00") end,
    },
    maxFrames = 17,
    transitions = {
        {
            state = "gura_default",
            minFrame = 18,
            conditions = {}
        },
        {
            state = "gura_airattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dashf01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_ADashB / Gura_ADashB
states.gura_airdashb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb01") end,
    },
    maxFrames = 3,
    transitions = {
        {
            state = "gura_airdashbend",
            minFrame = 4,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dashb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_ADashB / Gura_ADashB_End
states.gura_airdashbend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb01") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb02") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb01") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dashb03") end,
    },
    maxFrames = 18,
    transitions = {
        {
            state = "gura_default",
            minFrame = 19,
            conditions = {}
        },
        {
            state = "gura_airattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dashb01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_CCrouch / Gura_CCrouch
states.gura_crouch = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_crouch02") end,
    },
    maxFrames = 5,
    transitions = {
        {
            state = "gura_crouch2stand",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = -1
                },
            }
        },
        {
            state = "gura_crouchattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_crouch02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_CCrouchToStand / Gura_CCrouchToStand
states.gura_crouch2stand = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_crouch00") end,
    },
    maxFrames = 5,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 6,
            conditions = {}
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_stand2crouch",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_cheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkLight / Gura_SAtkLight
states.gura_slight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight00") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight01") end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight02") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight03") end,
    },
    maxFrames = 24,
    transitions = {
        {
            state = "gura_default",
            minFrame = 25,
            conditions = {}
        },
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
        {
            state = "gura_rollexcheck",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_rolllight",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "jump"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_cheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_cmedium",
            conditions = {
                {
                    parameter = "medium"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_smedium",
            conditions = {
                {
                    parameter = "medium"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_slightrestart",
            conditions = {
                {
                    parameter = "light"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_slight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkMedium / Gura_SAtkMedium
states.gura_smedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium02") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium03") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium04") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium05") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium06") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium07") end,
        [33] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium08") end,
        [38] = function(actor) actor:Sprite("sprite"):SetSprite("gura_smedium09") end,
    },
    maxFrames = 44,
    transitions = {
        {
            state = "gura_default",
            minFrame = 45,
            conditions = {}
        },
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
        {
            state = "gura_rollexcheck",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_rolllight",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "jump"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_cheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_smedium01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkHeavy / Gura_SAtkHeavy
states.gura_sheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy01") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy02") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy03") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy04") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy05") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy06") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy07") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sheavy08") end,
    },
    maxFrames = 43,
    transitions = {
        {
            state = "gura_default",
            minFrame = 44,
            conditions = {}
        },
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
        {
            state = "gura_rollexcheck",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_rolllight",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "jump"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_sheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkSpecial / Gura_SAtkSpecial_Start
states.gura_sspecialstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial02") end,
    },
    maxFrames = 13,
    transitions = {
        {
            state = "gura_sspecialhold",
            minFrame = 14,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_sspecial00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkSpecial / Gura_SAtkSpecial_Hold_Center
states.gura_sspecialhold = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial03") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial04") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial05") end,
    },
    maxFrames = 10,
    transitions = {
        {
            state = "gura_sspecialthrow",
            minFrame = 11,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_sspecial03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkSpecial / Gura_SAtkSpecial_Throw_Center
states.gura_sspecialthrow = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial06") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial07") end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "gura_sspecialend",
            minFrame = 7,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_sspecial06")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkSpecial / Gura_SAtkSpecial_End
states.gura_sspecialend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial08") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial09") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial10") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("gura_sspecial11") end,
    },
    maxFrames = 13,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 14,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_sspecial08")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_QCBRollLight / Gura_QCBRollLight
states.gura_rolllight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll03") end,
    },
    maxFrames = 15,
    transitions = {
        {
            state = "gura_rolllightend",
            minFrame = 16,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dodgeroll00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_QCBRollLight / Gura_QCBRollLight_End
states.gura_rolllightend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll03") end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "gura_clight",
            conditions = {
                {
                    parameter = "button"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_default",
            minFrame = 7,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dodgeroll03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_QCBRollMed / Gura_QCBRollMedium
states.gura_rollmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll03") end,
    },
    maxFrames = 15,
    transitions = {
        {
            state = "gura_rollmediumend",
            minFrame = 16,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dodgeroll00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_QCBRollMed / Gura_QCBRollMedium_End
states.gura_rollmediumend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll03") end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "gura_clight",
            conditions = {
                {
                    parameter = "button"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollattack",
            conditions = {
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_default",
            minFrame = 7,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dodgeroll03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_QCBRollEX / Gura_QCBRollEX
states.gura_rollex = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll03") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll04") end,
        [27] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll05") end,
    },
    maxFrames = 33,
    transitions = {
        {
            state = "gura_default",
            minFrame = 34,
            conditions = {}
        },
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_dodgeroll00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_QCBRollLowAttack / Gura_QCBRollLowAttack
states.gura_rolllow = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_crouch02") end,
    },
    maxFrames = 4,
    transitions = {
        {
            state = "gura_crouchattack",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_default",
            minFrame = 5,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_crouch02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_QCBRollMedAttack / Gura_QCBRollMedAttack
states.gura_rollattack = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_crouch02") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll04") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("gura_dodgeroll05") end,
    },
    maxFrames = 14,
    transitions = {
        {
            state = "gura_crouchattack",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_standingattack",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_default",
            minFrame = 15,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_crouch02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SGrabStart / Gura_GrabStart
states.gura_grabstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab02") end,
    },
    maxFrames = 5,
    transitions = {
        {
            state = "gura_grabsuccess",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_grabmiss",
            minFrame = 6,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_grab01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SGrabMiss / Gura_GrabWhiff
states.gura_grabmiss = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grabmiss00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grabmiss01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grabmiss00") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grabmiss01") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grabmiss02") end,
    },
    maxFrames = 25,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 26,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_grabmiss00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SGrabSuccess / Gura_GrabSuccess
states.gura_grabsuccess = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab03") end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab04") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab05") end,
        [27] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab06") end,
        [31] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab07") end,
        [41] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab08") end,
        [46] = function(actor) actor:Sprite("sprite"):SetSprite("gura_grab09") end,
    },
    maxFrames = 52,
    transitions = {
        {
            state = "gura_idle",
            minFrame = 53,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_grab02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SGrabTech / Gura_GrabTech
states.gura_grabtech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight01") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight02") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("gura_slight03") end,
    },
    maxFrames = 17,
    transitions = {
        {
            state = "gura_default",
            minFrame = 18,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_slight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- GrabBreak / Gura_GrabBreak
states.gura_grabbreak = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block00") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle00") end,
    },
    maxFrames = 17,
    transitions = {
        {
            state = "gura_default",
            minFrame = 18,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SAtkSuper / Gura_SAtkSuper
states.gura_super = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super00") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super01") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super02") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super03") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super04") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super05") end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super06") end,
        [55] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super04") end,
        [60] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super05") end,
        [65] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super06") end,
        [70] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super04") end,
        [75] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super05") end,
        [80] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super06") end,
        [85] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super04") end,
        [90] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super05") end,
        [95] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super06") end,
        [100] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super04") end,
        [105] = function(actor) actor:Sprite("sprite"):SetSprite("gura_super05") end,
    },
    maxFrames = 111,
    transitions = {
        {
            state = "gura_default",
            minFrame = 112,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_super00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AAtkLight / Gura_AAtkLight
states.gura_alight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_alight00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_alight01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_alight02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_alight03") end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("gura_alight04") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("gura_alight05") end,
    },
    maxFrames = 28,
    transitions = {
        {
            state = "gura_default",
            minFrame = 29,
            conditions = {}
        },
        {
            state = "gura_airjump",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "jump"
                },
            }
        },
        {
            state = "gura_airdashf",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_airdashb",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_amedium",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "medium"
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_aheavy",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "heavy"
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_idle",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_alight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AAtkMedium / Gura_AAtkMedium
states.gura_amedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_amedium00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_amedium01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_amedium02") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("gura_amedium03") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("gura_amedium04") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("gura_amedium05") end,
    },
    maxFrames = 30,
    transitions = {
        {
            state = "gura_default",
            minFrame = 31,
            conditions = {}
        },
        {
            state = "gura_airjump",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "jump"
                },
            }
        },
        {
            state = "gura_airdashf",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_airdashb",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_alight",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "light"
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_aheavy",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "heavy"
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_idle",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_amedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AAtkHeavy / Gura_AAtkHeavy
states.gura_aheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy02") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy03") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy04") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy05") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy06") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aheavy07") end,
    },
    maxFrames = 31,
    transitions = {
        {
            state = "gura_default",
            minFrame = 32,
            conditions = {}
        },
        {
            state = "gura_idle",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_aheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AAtkSpecial / Gura_AAtkSpecial_Start
states.gura_aspecialstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial02") end,
    },
    maxFrames = 13,
    transitions = {
        {
            state = "gura_aspecialhold",
            minFrame = 14,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_aspecial00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AAtkSpecial / Gura_AAtkSpecial_Hold_Center
states.gura_aspecialhold = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial12") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial13") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial14") end,
    },
    maxFrames = 10,
    transitions = {
        {
            state = "gura_aspecialthrow",
            minFrame = 11,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_aspecial12")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AAtkSpecial / Gura_AAtkSpecial_Throw_Center
states.gura_aspecialthrow = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial15") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial07") end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "gura_aspecialend",
            minFrame = 7,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_aspecial15")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_AAtkSpecial / Gura_AAtkSpecial_End
states.gura_aspecialend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial07") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial08") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial09") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial10") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_aspecial11") end,
    },
    maxFrames = 16,
    transitions = {
        {
            state = "gura_airrise",
            minFrame = 17,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_aspecial07")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_CAtkLight / Gura_CAtkLight
states.gura_clight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_clight00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_clight01") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_clight02") end,
    },
    maxFrames = 20,
    transitions = {
        {
            state = "gura_crouch",
            minFrame = 21,
            conditions = {}
        },
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
        {
            state = "gura_rollexcheck",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_rolllight",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "jump"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_cheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_cmedium",
            conditions = {
                {
                    parameter = "medium"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_clightrestart",
            conditions = {
                {
                    parameter = "light"
                },
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_smedium",
            conditions = {
                {
                    parameter = "medium"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_slight",
            conditions = {
                {
                    parameter = "light"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_clight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_CAtkMedium / Gura_CAtkMedium
states.gura_cmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cmedium01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cmedium02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cmedium03") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cmedium04") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cmedium05") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cmedium06") end,
    },
    maxFrames = 41,
    transitions = {
        {
            state = "gura_crouch",
            minFrame = 42,
            conditions = {}
        },
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "jump"
                },
            }
        },
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "doubleForward"
                },
            }
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "doubleBack"
                },
            }
        },
        {
            state = "gura_rollexcheck",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_rolllight",
            conditions = {
                {
                    parameter = "light"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {
                {
                    parameter = "qcb"
                },
                {
                    parameter = "medium"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_cheavy",
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
                {
                    parameter = "heavy"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sheavy",
            conditions = {
                {
                    parameter = "heavy"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_smedium",
            conditions = {
                {
                    parameter = "medium"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_cheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_CAtkHeavy / Gura_CAtkHeavy
states.gura_cheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy03") end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy04") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy05") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy06") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy07") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy08") end,
        [36] = function(actor) actor:Sprite("sprite"):SetSprite("gura_cheavy09") end,
    },
    maxFrames = 43,
    transitions = {
        {
            state = "gura_crouch",
            minFrame = 44,
            conditions = {}
        },
        {
            state = "gura_super",
            conditions = {
                {
                    parameter = "exBars",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 1
                },
                {
                    parameter = "grab"
                },
                {
                    parameter = "qcf"
                },
            }
        },
        {
            state = "gura_rollexcheck",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "heavy"
                },
            }
        },
        {
            state = "gura_rolllight",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "light"
                },
            }
        },
        {
            state = "gura_rollmedium",
            conditions = {
                {
                    parameter = "hitConfirm"
                },
                {
                    parameter = "qcb"
                },
                {
                    parameter = "medium"
                },
            }
        },
        {
            state = "gura_jumpstart",
            conditions = {
                {
                    parameter = "jump"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashfstart",
            conditions = {
                {
                    parameter = "doubleForward"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_dashb",
            conditions = {
                {
                    parameter = "doubleBack"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
        {
            state = "gura_sspecialstart",
            conditions = {
                {
                    parameter = "special"
                },
                {
                    parameter = "hitConfirm"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_cheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitS / Gura_HitSStart
states.gura_hitsstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hits00") end,
    },
    maxFrames = 2,
    transitions = {
        {
            state = "gura_default",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
            }
        },
        {
            state = "gura_hitsend",
            minFrame = 3,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_hits00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitS / Gura_HitSEnd
states.gura_hitsend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hits01") end,
    },
    maxFrames = 3,
    transitions = {
        {
            state = "gura_default",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_hits01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitA / Gura_HitA_Rise
states.gura_hitrise = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hita00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hita01") end,
    },
    maxFrames = 3,
    transitions = {
        {
            state = "gura_knockdown",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
                {
                    parameter = "vVelocity",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0.1
                },
            }
        },
        {
            state = "gura_tech",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_hitapex",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.0 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_hita00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitA / Gura_HitA_Rise2Fall
states.gura_hitapex = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hita02") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hita03") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hita04") end,
    },
    maxFrames = 7,
    transitions = {
        {
            state = "gura_knockdown",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
                {
                    parameter = "vVelocity",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0.1
                },
            }
        },
        {
            state = "gura_tech",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
                {
                    parameter = "button"
                },
            }
        },
        {
            state = "gura_hitfall",
            minFrame = 8,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_hita02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitA / Gura_HitA_Fall
states.gura_hitfall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hita05") end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "gura_knockdown",
            conditions = {
                {
                    parameter = "inAir",
                    value = false
                },
                {
                    parameter = "vVelocity",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0.1
                },
            }
        },
        {
            state = "gura_tech",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
                {
                    parameter = "button"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_hita05")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitTech / Gura_Tech
states.gura_tech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_tech00") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_tech01") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_tech02") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_tech03") end,
    },
    maxFrames = 26,
    transitions = {
        {
            state = "gura_default",
            minFrame = 27,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_tech00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitKnockdownStart / Gura_Knockdown_Start
states.gura_knockdownstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown00") end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "gura_knockdown",
            minFrame = 7,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_knockdown00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitKnockdown / Gura_Knockdown
states.gura_knockdown = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown01") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown02") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown03") end,
    },
    maxFrames = 26,
    transitions = {
        {
            state = "gura_getup",
            minFrame = 27,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_knockdown01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitKnockdown / Gura_Knockdown_Getup
states.gura_getup = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown04") end,
    },
    maxFrames = 9,
    transitions = {
        {
            state = "gura_dead",
            conditions = {
                {
                    parameter = "isDead",
                    value = true
                },
            }
        },
        {
            state = "gura_crouch",
            minFrame = 10,
            conditions = {
                {
                    parameter = "vInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                },
            }
        },
        {
            state = "gura_default",
            minFrame = 10,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_knockdown04")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitKnockdownDead / Gura_Knockdown_Dead
states.gura_dead = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown03") end,
    },
    maxFrames = 2,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_knockdown03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_Burst / Gura_Burst
states.gura_burst = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst00") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst01") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst02") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst03") end,
        [27] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst01") end,
        [32] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst02") end,
        [37] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst03") end,
        [42] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst01") end,
        [47] = function(actor) actor:Sprite("sprite"):SetSprite("gura_burst02") end,
    },
    maxFrames = 51,
    transitions = {
        {
            state = "gura_default",
            minFrame = 52,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_burst00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SWasGrabbed / Gura_GrabbedByGura_Start
states.gura_grabbedstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block00") end,
    },
    maxFrames = 5,
    transitions = {
        {
            state = "gura_grabtech",
            conditions = {
                {
                    parameter = "grab"
                },
            }
        },
        {
            state = "gura_grabbedend",
            minFrame = 6,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SWasGrabbed: choose the matching grab recovery once on entry.
states.gura_grabbedend = {
    onEnter = function(actor)
        local variant = actor:Animator():GetInt("grabId") % 3
        if variant == 0 then return "gura_grabbedend_gura" end
        if variant == 1 then return "gura_grabbedend_ina" end
        return "gura_grabbedend_kiara"
    end
}

-- Gura_SWasGrabbed / Gura_GrabbedByGura_End
states.gura_grabbedend_gura = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block00") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown00") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown01") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_knockdown02") end,
    },
    maxFrames = 43,
    transitions = {
        {
            state = "gura_default",
            minFrame = 44,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SWasGrabbed / Gura_GrabbedByIna_End
states.gura_grabbedend_ina = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block00") end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("") end,
    },
    maxFrames = 45,
    transitions = {
        {
            state = "gura_default",
            minFrame = 46,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_SWasGrabbed / Gura_GrabbedByKiara_End
states.gura_grabbedend_kiara = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hits00") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_hita01") end,
    },
    maxFrames = 60,
    transitions = {
        {
            state = "gura_default",
            minFrame = 61,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_hits00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitBlockedC / Gura_BlockC
states.gura_blockc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block01") end,
    },
    maxFrames = 2,
    transitions = {
        {
            state = "gura_crouch",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
            }
        },
        {
            state = "gura_pushblock",
            conditions = {
                {
                    parameter = "grab"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitBlockedA / Gura_BlockA
states.gura_blocka = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block02") end,
    },
    maxFrames = 2,
    transitions = {
        {
            state = "gura_default",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
            }
        },
        {
            state = "gura_pushblock",
            conditions = {
                {
                    parameter = "grab"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_HitBlockedS / Gura_BlockS
states.gura_blocks = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block00") end,
    },
    maxFrames = 2,
    transitions = {
        {
            state = "gura_default",
            conditions = {
                {
                    parameter = "hitStun",
                    value = false
                },
            }
        },
        {
            state = "gura_pushblock",
            conditions = {
                {
                    parameter = "grab"
                },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_PushBlockA / Gura_PushblockA
states.gura_pushblocka = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block02") end,
    },
    maxFrames = 16,
    transitions = {
        {
            state = "gura_default",
            minFrame = 17,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_PushBlockC / Gura_PushblockC
states.gura_pushblockc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block01") end,
    },
    maxFrames = 16,
    transitions = {
        {
            state = "gura_default",
            minFrame = 17,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Gura_PushBlockS / Gura_PushblockS
states.gura_pushblocks = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_block00") end,
    },
    maxFrames = 16,
    transitions = {
        {
            state = "gura_default",
            minFrame = 17,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        -- Add state-specific cleanup here.
    end
}

-- Restart through a visible entry state: native SetCurrentState ignores the current state.
states.gura_slightrestart = {
    onEnter = function(actor)
        return "gura_slight"
    end
}

-- Restart through a visible entry state: native SetCurrentState ignores the current state.
states.gura_clightrestart = {
    onEnter = function(actor)
        return "gura_clight"
    end
}

return states
