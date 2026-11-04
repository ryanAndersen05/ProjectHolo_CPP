local states = {}

local StateMachineCommon = require("assets.animation.statemachine")

states.parameters = {
    ["doubleForward"] = StateMachineCommon.EParameterType.Trigger,
    ["doubleBack"] = StateMachineCommon.EParameterType.Trigger,
    ["doubleDown"] = StateMachineCommon.EParameterType.Trigger,
    ["qcf"] = StateMachineCommon.EParameterType.Trigger,
    ["qcb"] = StateMachineCommon.EParameterType.Trigger,
    ["doubleQcf"] = StateMachineCommon.EParameterType.Trigger,
    ["hInput"] = StateMachineCommon.EParameterType.Int,
    ["vInput"] = StateMachineCommon.EParameterType.Int,
    ["inAir"] = StateMachineCommon.EParameterType.Bool,
    ["vVelocity"] = StateMachineCommon.EParameterType.Float,
    ["airJump"] = StateMachineCommon.EParameterType.Int,
    ["airDash"] = StateMachineCommon.EParameterType.Int,
    ["jump"] = StateMachineCommon.EParameterType.Trigger,
    ["button"] = StateMachineCommon.EParameterType.Trigger,
    ["light"] = StateMachineCommon.EParameterType.Trigger,
    ["medium"] = StateMachineCommon.EParameterType.Trigger,
    ["heavy"] = StateMachineCommon.EParameterType.Trigger,
    ["heavyHeld"] = StateMachineCommon.EParameterType.Bool,
    ["special"] = StateMachineCommon.EParameterType.Trigger,
    ["lightRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["lightHeld"] = StateMachineCommon.EParameterType.Bool,
    ["mediumRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["mediumHeld"] = StateMachineCommon.EParameterType.Bool,
    ["heavyRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["specialRelease"] = StateMachineCommon.EParameterType.Trigger,
    ["specialHeld"] = StateMachineCommon.EParameterType.Bool,
    ["grab"] = StateMachineCommon.EParameterType.Trigger,
    ["grabId"] = StateMachineCommon.EParameterType.Int,
    ["burst"] = StateMachineCommon.EParameterType.Trigger,
    ["blockBurst"] = StateMachineCommon.EParameterType.Bool,
    ["exBars"] = StateMachineCommon.EParameterType.Int,
    ["hitConfirm"] = StateMachineCommon.EParameterType.Trigger,
    ["wasHit"] = StateMachineCommon.EParameterType.Trigger,
    ["hitStun"] = StateMachineCommon.EParameterType.Bool,
    ["isDead"] = StateMachineCommon.EParameterType.Bool,
    ["hitType"] = StateMachineCommon.EParameterType.Int,
    ["win"] = StateMachineCommon.EParameterType.Trigger,
}

states.defaultState = "ina_default"
states.spriteAsset = "ina_atlas"

states.any_state = {
    transitions = {
        {
            state = "ina_washit",
            conditions = {
                { parameter = "wasHit" },
            }
        },
        {
            state = "ina_burst",
            conditions = {
                { parameter = "burst" },
                { parameter = "blockBurst", value = false },
            }
        },
    },
    tick = function(self, actor, frame)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end
}

states.ina_default = {
    transitions = {
        {
            state = "ina_airrise",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "ina_idle",
            conditions = {}
        },
    },
    tick = function(self, actor, frame)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
}

states.ina_idle = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle00") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle01") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle02") end,
        [21] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle03") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle04") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle05") end,
        [42] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle06") end,
        [49] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle07") end
    },
    transitions = {
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_win",
            conditions = {
                { parameter = "win" },
            }
        },
        {
            state = "ina_walkf",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = 0
                }

            }
        },
        {
            state = "ina_walkb",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                }

            }
        },
    },
    maxFrames = 56,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_idle00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Idle)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
}

states.ina_walkf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkf00") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkf01") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkf02") end
    },
    maxFrames = 21,
    transitions = {
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_walkfend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 1 },
            }
        },
        {
            state = "ina_idle",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 1
                }

            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_walkf00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Walk)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
}

states.ina_walkb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkb00") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkb01") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkb02") end
    },
    maxFrames = 21,
    transitions = {
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_walkbend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = -1 },
            }
        },
        {
            state = "ina_idle",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = -1
                }

            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_walkb00")
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

states.ina_dashf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf03") end
    },
    maxFrames = 20,
    transitions = {
        {
            state = "ina_crouchingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_dashfend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 1 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Dash)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
}

states.ina_dashb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb03") end
    },
    maxFrames = 20,
    transitions = {
        {
            state = "ina_default",
            minFrame = 21,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashb00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Dash)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
}

states.ina_stand2crouch = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_crouch00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_crouch01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_crouch02") end
    },
    maxFrames = 15,
    transitions = {
        {
            state = "ina_crouch",
            minFrame = 16,
            conditions = {}
        },
        {
            state = "ina_crouch2stand",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = -1 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_crouch00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.ina_crouch2stand = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_crouch03") end
    },
    maxFrames = 5,
    transitions = {
        {
            state = "ina_idle",
            minFrame = 6,
            conditions = {}
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_crouch03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.ina_jump = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_jump00") end
    },
    maxFrames = 5,
    transitions = {
        {
            state = "ina_airrise",
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump00")
        actor:Movement():Jump()
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.ina_rise2fall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_jump01") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_jump02") end
    },
    maxFrames = 10,
    transitions = {
        {
            state = "ina_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "ina_airjump",
            conditions = {
                { parameter = "jump" },
            }
        },
        {
            state = "ina_airdashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_airdashf",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_fall",
            minFrame = 11,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.ina_fall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_jump03") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_jump04") end
    },
    maxFrames = 10,
    transitions = {
        {
            state = "ina_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "ina_airjump",
            conditions = {
                { parameter = "jump" },
            }
        },
        {
            state = "ina_airdashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_airdashf",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.ina_hits = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hits00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hits01") end
    },
    maxFrames = 10,
    transitions = {
        {
            state = "ina_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
        {
            state = "ina_hitsend",
            minFrame = 11,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hits00")
    end,
    tick = function(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end,
    onExit = function(actor)

    end
}

states.ina_hitc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hitc00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hitc01") end
    },
    maxFrames = 10,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hitc00")
    end,
    tick = function(self, actor, frame)
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end,
    onExit = function(actor)

    end
}

states.ina_hita = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita06") end
    },
    maxFrames = 35,
    transitions = {
        {
            state = "ina_knockdown",
            conditions = {
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.1 },
            }
        },
        {
            state = "ina_tech",
            conditions = {
                { parameter = "hitStun", value = false },
                { parameter = "button" },
            }
        },
        {
            state = "ina_hitarise2fall",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hita00")
    end,
    tick = function(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end,
    onExit = function(actor)

    end
}

states.ina_blocks = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks02") end
    },
    maxFrames = 15,
    transitions = {
        {
            state = "ina_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
        {
            state = "ina_pushblock",
            conditions = {
                { parameter = "grab" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.ina_standingattack = {
    transitions = {
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "doubleQcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "heavy" },
                { parameter = "qcf" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "heavy" },
                { parameter = "qcb" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "medium" },
                { parameter = "qcf" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "light" },
                { parameter = "qcf" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "light" },
                { parameter = "qcb" },
            }
        },
        {
            state = "ina_grabstart",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
            }
        },
        {
            state = "ina_sheavy",
            conditions = {
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_smedium",
            conditions = {
                { parameter = "medium" },
            }
        },
        {
            state = "ina_slight",
            conditions = {
                { parameter = "light" },
            }
        },
        {
            state = "ina_slight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_standingattack, states.parameters)
    end
}

states.ina_slight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight00") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight01") end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight02") end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight03") end,
    },
    maxFrames = 24,
    transitions = {
        {
            state = "ina_default",
            minFrame = 25,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "jump" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "doubleQcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_cheavy",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_cmedium",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_sheavy",
            conditions = {
                { parameter = "heavy" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_smedium",
            conditions = {
                { parameter = "medium" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_slightfollowup",
            conditions = {
                { parameter = "light" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_slightfollowup",
            conditions = {
                {
                    parameter = "light"
                }

            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_slight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_slightfollowup = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight04") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight05") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight06") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight07") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight08") end,
        [29] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight09") end
    },
    transitions = {
        {
            state = "ina_default",
            minFrame = 38,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "jump" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "doubleQcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_cheavy",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_cmedium",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_sheavy",
            conditions = {
                { parameter = "heavy" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_smedium",
            conditions = {
                { parameter = "medium" },
                { parameter = "hitConfirm" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_slight04")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end,
    maxFrames = 37,
}

states.ina_smedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium01") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium03") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium04") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium05") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium06") end,
        [29] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium07") end,
        [33] = function(actor) actor:Sprite("sprite"):SetSprite("ina_smedium08") end
    },
    maxFrames = 38,
    transitions = {
        {
            state = "ina_default",
            minFrame = 39,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "jump" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "doubleQcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_cheavy",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_sheavy",
            conditions = {
                { parameter = "heavy" },
                { parameter = "hitConfirm" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_smedium01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_sheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy01") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy02") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy03") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy04") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy05") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy06") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy07") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy06") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy08") end,
        [29] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy09") end,
        [34] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sheavy10") end,
    },
    maxFrames = 39,
    transitions = {
        {
            state = "ina_default",
            minFrame = 40,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "jump" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "doubleQcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
                { parameter = "hitConfirm" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_sheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_sspecial = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial06") end
    },
    maxFrames = 35,
    transitions = {
        {
            state = "ina_default",
            minFrame = 36,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_sspecial00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_ssuper = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper08") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper09") end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper10") end,
        [55] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper11") end,
        [60] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper12") end
    },
    maxFrames = 65,
    transitions = {
        {
            state = "ina_default",
            minFrame = 66,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_ssuper00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_crouchingattack = {
    transitions = {
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
            }
        },
        {
            state = "ina_cheavy",
            conditions = {
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_cmedium",
            conditions = {
                { parameter = "medium" },
            }
        },
        {
            state = "ina_clight",
            conditions = {
                { parameter = "light" },
            }
        },
        {
            state = "ina_clight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_crouchingattack, states.parameters)
    end,
}

states.ina_clight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_clight00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_clight01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_clight02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_clight03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_clight04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_clight05") end
    },
    maxFrames = 30,
    transitions = {
        {
            state = "ina_crouch",
            minFrame = 31,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "jump" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "doubleQcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_cheavy",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_cmedium",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_sheavy",
            conditions = {
                { parameter = "heavy" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_smedium",
            conditions = {
                { parameter = "medium" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_slight",
            conditions = {
                { parameter = "light" },
                { parameter = "hitConfirm" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_clight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_cmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium07") end
    },
    maxFrames = 40,
    transitions = {
        {
            state = "ina_crouch",
            minFrame = 41,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "jump" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "doubleQcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_cheavy",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_sheavy",
            conditions = {
                { parameter = "heavy" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_smedium",
            conditions = {
                { parameter = "medium" },
                { parameter = "hitConfirm" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_cmedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_cheavy = {
    keyFrames = {
        [0] = function(actor)
            actor:Sprite("sprite"):SetSprite("ina_cheavy00")
            actor:Sprite("altSprite"):SetSprite("ina_cheavytentacle00")
        end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavy08") end
    },
    maxFrames = 45,
    transitions = {
        {
            state = "ina_crouch",
            minFrame = 46,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "jump" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_ssuper",
            conditions = {
                { parameter = "doubleQcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_qcfexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcf" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_qcbexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_qcb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_qcbmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "qcb" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_sspecial",
            conditions = {
                { parameter = "special" },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_sheavy",
            conditions = {
                { parameter = "heavy" },
                { parameter = "hitConfirm" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_cheavy00")
        actor:Sprite("altSprite"):SetSprite("")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)
        actor:Sprite("altSprite"):SetSprite("") -- reset alt sprite to disabled
    end
}

states.ina_cheavytentacle = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavytentacle00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavytentacle01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavytentacle02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavytentacle03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavytentacle04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cheavytentacle05") end
    },
    maxFrames = 30,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_cheavytentacle00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_airattack = {
    transitions = {
        {
            state = "ina_asuper",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "doubleQcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_aspecial",
            conditions = {
                { parameter = "special" },
            }
        },
        {
            state = "ina_aheavy",
            conditions = {
                { parameter = "heavy" },
            }
        },
        {
            state = "ina_amedium",
            conditions = {
                { parameter = "medium" },
            }
        },
        {
            state = "ina_alight",
            conditions = {
                { parameter = "light" },
            }
        },
        {
            state = "ina_alight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_airattack, states.parameters)
    end,
}

states.ina_alight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_alight00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_alight01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_alight02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_alight03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_alight04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_alight05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_alight06") end
    },
    maxFrames = 35,
    transitions = {
        {
            state = "ina_default",
            minFrame = 36,
            conditions = {}
        },
        {
            state = "ina_default",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "ina_asuper",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "doubleQcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "ina_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_aspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
        {
            state = "ina_amedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
        {
            state = "ina_aheavy",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_alight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_aheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy08") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavy09") end
    },
    maxFrames = 50,
    transitions = {
        {
            state = "ina_default",
            minFrame = 51,
            conditions = {}
        },
        {
            state = "ina_default",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "ina_asuper",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "doubleQcf" },
                { parameter = "lightHeld", value = false },
            }
        },
        {
            state = "ina_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "ina_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_aspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_aheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_aheavyfist = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_aheavyfist08") end
    },
    maxFrames = 45,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_aheavyfist00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_qcf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf08") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf09") end
    },
    maxFrames = 50,
    transitions = {
        {
            state = "ina_default",
            minFrame = 51,
            conditions = {}
        },
        {
            state = "ina_crouchingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "hitConfirm" },
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "hitConfirm" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_qcb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb07") end
    },
    maxFrames = 40,
    transitions = {
        {
            state = "ina_default",
            minFrame = 41,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_grab = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab08") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab09") end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab10") end,
        [55] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab11") end,
        [60] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab12") end,
        [65] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab13") end,
        [70] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab14") end,
        [75] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab15") end
    },
    maxFrames = 80,
    transitions = {
        {
            state = "ina_default",
            minFrame = 81,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_grab00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_grabtech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech03") end
    },
    maxFrames = 20,
    transitions = {
        {
            state = "ina_default",
            minFrame = 21,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_grabtech00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_tech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech03") end
    },
    maxFrames = 20,
    transitions = {
        {
            state = "ina_default",
            minFrame = 21,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_tech00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_knockdown = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown07") end
    },
    maxFrames = 40,
    transitions = {
        {
            state = "ina_getup",
            minFrame = 41,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_knockdown00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
    end,
    onExit = function(actor)

    end
}

states.ina_burst = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burst00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burst01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burst02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burst03") end
    },
    maxFrames = 20,
    transitions = {
        {
            state = "ina_default",
            minFrame = 21,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_burst00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_burstexp = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burstexp00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burstexp01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burstexp02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_burstexp03") end
    },
    maxFrames = 20,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_burstexp00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_beam = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam08") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam09") end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam10") end,
        [55] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam11") end,
        [60] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam12") end,
        [65] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam13") end,
        [70] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam14") end,
        [75] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam15") end,
        [80] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam16") end,
        [85] = function(actor) actor:Sprite("sprite"):SetSprite("ina_beam17") end
    },
    maxFrames = 90,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_beam00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_portal = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal07") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal08") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal09") end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal10") end,
        [55] = function(actor) actor:Sprite("sprite"):SetSprite("ina_portal11") end
    },
    maxFrames = 60,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_portal00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_tentacle = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tentacle00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tentacle01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tentacle02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tentacle03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tentacle04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tentacle05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tentacle06") end
    },
    maxFrames = 35,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_tentacle00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_lightning = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_lightning00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_lightning01") end
    },
    maxFrames = 10,
    transitions = {
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_lightning00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
    end,
    onExit = function(actor)

    end
}

states.ina_win = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win07") end
    },
    maxFrames = 40,
    transitions = {
        {
            state = "ina_winend",
            minFrame = 41,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_win00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
    end,
    onExit = function(actor)

    end
}

-- Ina_SWalkF / Ina_SWalkF_Start
states.ina_walkfstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf00") end,
    },
    maxFrames = 6,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_walkf",
            minFrame = 7,
            conditions = {}
        },
    },
}

-- Ina_SWalkF / Ina_SWalkF_End
states.ina_walkfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf00") end,
    },
    maxFrames = 6,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_idle",
            minFrame = 7,
            conditions = {}
        },
        {
            state = "ina_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
}

-- Ina_SWalkB / Ina_SWalkB_Start
states.ina_walkbstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkb00") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_walkb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_walkb",
            minFrame = 4,
            conditions = {}
        },
    },
}

-- Ina_SWalkB / Ina_SWalkB_End
states.ina_walkbend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_walkb00") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_walkb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_idle",
            minFrame = 4,
            conditions = {}
        },
        {
            state = "ina_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
}

-- Ina_SDashF / Ina_SDashF_Start
states.ina_dashfstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf00") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf01") end,
    },
    maxFrames = 7,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_dashf",
            minFrame = 8,
            conditions = {}
        },
    },
}

-- Ina_SDashF / Ina_SDashF_End
states.ina_dashfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf03") end,
    },
    maxFrames = 7,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 8,
            conditions = {}
        },
        {
            state = "ina_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
}

-- Ina_Win / Ina_Win_End
states.ina_winend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win06") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_win07") end,
    },
    maxFrames = 36,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_win06")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
    },
}

-- Ina_AInAir / Ina_ARising
states.ina_airrise = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_jump00") end,
    },
    maxFrames = 4,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "ina_airjump",
            conditions = {
                { parameter = "jump" },
            }
        },
        {
            state = "ina_airdashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_airdashf",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_rise2fall",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
}

-- Ina_AJump / Ina_AJump
states.ina_airjump = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_jump00") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_airrise",
            minFrame = 4,
            conditions = {}
        },
    },
}

-- Ina_ADashF / Ina_ADashF
states.ina_airdashf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf01") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_airdashfend",
            minFrame = 4,
            conditions = {}
        },
    },
}

-- Ina_ADashF / Ina_ADashF_End
states.ina_airdashfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf01") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf01") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf01") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf02") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf01") end,
        [21] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashf03") end,
    },
    maxFrames = 24,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 25,
            conditions = {}
        },
        {
            state = "ina_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
}

-- Ina_ADashB / Ina_ADashB
states.ina_airdashb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb01") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_airdashbend",
            minFrame = 4,
            conditions = {}
        },
    },
}

-- Ina_ADashB / Ina_ADashB_End
states.ina_airdashbend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb01") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb01") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb02") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb01") end,
        [21] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb02") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("ina_dashb03") end,
    },
    maxFrames = 27,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 28,
            conditions = {}
        },
        {
            state = "ina_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
}

-- Ina_CCrouch / Ina_CCrouch
states.ina_crouch = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_cmedium00") end,
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_cmedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_crouchingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "ina_crouch2stand",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = -1 },
            }
        },
    },
}

-- Ina_SGrabStart / Ina_GrabStart
states.ina_grabstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab01") end,
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_grab00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_grab",
            conditions = {
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "ina_grabmiss",
            minFrame = 6,
            conditions = {}
        },
    },
}

-- Ina_SGrabMiss / Ina_GrabWhiff
states.ina_grabmiss = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab10") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab12") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab13") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab14") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grab15") end,
    },
    maxFrames = 26,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_grab10")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 27,
            conditions = {}
        },
    },
}

-- Ina_SQCF_M / Ina_QCF_M
states.ina_qcfmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf01") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf02") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf03") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf04") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf05") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf06") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf07") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf08") end,
        [48] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf09") end,
    },
    maxFrames = 51,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcf01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 52,
            conditions = {}
        },
        {
            state = "ina_crouchingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "hitConfirm" },
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_standingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "hitConfirm" },
            }
        },
    },
}

-- Ina_SQCF_EX / Ina_QCF_EX
states.ina_qcfex = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf03") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf04") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf05") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf06") end,
        [27] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf07") end,
        [34] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf08") end,
        [38] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcf09") end,
    },
    maxFrames = 41,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcf01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 42,
            conditions = {}
        },
    },
}

-- Ina_SQCB_M / Ina_QCB_M
states.ina_qcbmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb01") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb02") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb03") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb04") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb05") end,
    },
    maxFrames = 41,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcb01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 42,
            conditions = {}
        },
    },
}

-- Ina_SQCB_EX / Ina_QCB_EX
states.ina_qcbex = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb01") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb02") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb03") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb04") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb05") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb03") end,
        [26] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb04") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb05") end,
        [34] = function(actor) actor:Sprite("sprite"):SetSprite("ina_qcb06") end,
    },
    maxFrames = 35,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcb01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 36,
            conditions = {}
        },
    },
}

-- Ina_AAtkMedium / Ina_AAtkMedium
states.ina_amedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium02") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium03") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium04") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium05") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium06") end,
        [21] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium07") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium08") end,
        [29] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium09") end,
        [33] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium10") end,
        [37] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium11") end,
        [41] = function(actor) actor:Sprite("sprite"):SetSprite("ina_amedium12") end,
    },
    maxFrames = 46,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_amedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 47,
            conditions = {}
        },
        {
            state = "ina_default",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "ina_asuper",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "doubleQcf" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "ina_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "ina_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "ina_aspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
        {
            state = "ina_alight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "light" },
            }
        },
        {
            state = "ina_aheavy",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
    },
}

-- Ina_AAtkSpecial / Ina_AAtkSpecial
states.ina_aspecial = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial01") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial02") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial03") end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial04") end,
        [26] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial05") end,
        [31] = function(actor) actor:Sprite("sprite"):SetSprite("ina_sspecial06") end,
    },
    maxFrames = 40,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_sspecial00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 41,
            conditions = {}
        },
    },
}

-- Ina_AAtkSuper / Ina_AAtkSuper
states.ina_asuper = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper01") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper03") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper04") end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper05") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper06") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper07") end,
        [38] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper09") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper10") end,
        [49] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper11") end,
        [53] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper09") end,
        [57] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper10") end,
        [61] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper11") end,
        [65] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper09") end,
        [69] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper10") end,
        [73] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper11") end,
        [77] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper09") end,
        [81] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper10") end,
        [85] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper11") end,
        [89] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper09") end,
        [93] = function(actor) actor:Sprite("sprite"):SetSprite("ina_ssuper10") end,
    },
    maxFrames = 98,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_ssuper01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 99,
            conditions = {}
        },
    },
}

-- Ina_HitS / Ina_HitSEnd
states.ina_hitsend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hits01") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hits01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
    },
}

-- Ina_HitA / Ina_HitA_Rise2Fall
states.ina_hitarise2fall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita03") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita04") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita05") end,
    },
    maxFrames = 8,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hita03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_knockdown",
            conditions = {
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.1 },
            }
        },
        {
            state = "ina_tech",
            conditions = {
                { parameter = "hitStun", value = false },
                { parameter = "button" },
            }
        },
        {
            state = "ina_hitafall",
            minFrame = 9,
            conditions = {}
        },
    },
}

-- Ina_HitA / Ina_HitA_Fall
states.ina_hitafall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita05") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita06") end,
    },
    maxFrames = 9,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hita05")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_knockdown",
            conditions = {
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.1 },
            }
        },
        {
            state = "ina_tech",
            conditions = {
                { parameter = "hitStun", value = false },
                { parameter = "button" },
            }
        },
    },
}

-- Ina_HitKnockdownStart / Ina_Knockdown_Start
states.ina_knockdownstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown00") end,
    },
    maxFrames = 6,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_knockdown00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_knockdown",
            minFrame = 7,
            conditions = {}
        },
    },
}

-- Ina_HitKnockdown / Ina_Knockdown_Getup
states.ina_getup = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown03") end,
        [1] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown04") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown05") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown07") end,
    },
    maxFrames = 9,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_knockdown03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_dead",
            conditions = {
                { parameter = "isDead", value = true },
            }
        },
        {
            state = "ina_crouch",
            minFrame = 10,
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_default",
            minFrame = 10,
            conditions = {}
        },
    },
}

-- Ina_HitKnockdownDead / Ina_Knockdown_Dead
states.ina_dead = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown02") end,
    },
    maxFrames = 1,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_knockdown02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
    },
}

-- Ina_SWasGrabbed / Ina_GrabbedByGura_Start
states.ina_grabbedstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks01") end,
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_grabtech",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "ina_grabbedend",
            minFrame = 6,
            conditions = {}
        },
    },
}

-- Ina_SWasGrabbed / Ina_GrabbedByGura_End
states.ina_grabbedend = {
    onEnter = function(actor)
        local grabId = actor:Animator():GetInt("grabId") % 3
        if grabId == 0 then return "ina_grabbedend_gura"
        elseif grabId == 1 then return "ina_grabbedend_ina"
        else return "ina_grabbedend_kiara" end
    end,
}

-- GrabBreak / Ina_GrabBreak
states.ina_grabbreak = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("ina_idle00") end,
    },
    maxFrames = 17,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 18,
            conditions = {}
        },
    },
}

-- Ina_HitBlockedC / Ina_BlockC
states.ina_blockc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks02") end,
    },
    maxFrames = 2,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_crouch",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
        {
            state = "ina_pushblock",
            conditions = {
                { parameter = "grab" },
            }
        },
    },
}

-- Ina_HitBlockedA / Ina_BlockA
states.ina_blocka = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks00") end,
    },
    maxFrames = 2,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
        {
            state = "ina_pushblock",
            conditions = {
                { parameter = "grab" },
            }
        },
    },
}

-- Ina_PushBlockA / Ina_PushblockA
states.ina_pushblocka = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks00") end,
    },
    maxFrames = 16,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 17,
            conditions = {}
        },
    },
}

-- Ina_PushBlockC / Ina_PushblockC
states.ina_pushblockc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks02") end,
    },
    maxFrames = 16,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 17,
            conditions = {}
        },
    },
}

-- Ina_PushBlockS / Ina_PushblockS
states.ina_pushblocks = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks01") end,
    },
    maxFrames = 16,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 17,
            conditions = {}
        },
    },
}

-- Ina_SWasGrabbed / Ina_GrabbedByGura_End
states.ina_grabbedend_gura = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks01") end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown00") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_knockdown01") end,
    },
    maxFrames = 42,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 43,
            conditions = {}
        },
    },
}

-- Ina_SWasGrabbed / Ina_GrabbedByIna_End
states.ina_grabbedend_ina = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks01") end,
    },
    maxFrames = 45,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 46,
            conditions = {}
        },
    },
}

-- Ina_SWasGrabbed / Ina_GrabbedByKiara_End
states.ina_grabbedend_kiara = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hits00") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_hita02") end,
    },
    maxFrames = 60,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hits00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "ina_default",
            minFrame = 61,
            conditions = {}
        },
    },
}

-- Ina_SQCF_EXTrans
states.ina_qcfexcheck = {
    transitions = {
        {
            state = "ina_qcfex",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_qcfmedium",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_qcfexcheck, states.parameters)
    end,
}

-- Ina_SQCB_EXTrans
states.ina_qcbexcheck = {
    transitions = {
        {
            state = "ina_qcbex",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_qcb",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_qcbexcheck, states.parameters)
    end,
}

-- Ina_Blocked
states.ina_blocked = {
    transitions = {
        {
            state = "ina_blocka",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "ina_blockc",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_blocks",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_blocked, states.parameters)
    end,
}

-- Ina_WasHit
states.ina_washit = {
    transitions = {
        {
            state = "ina_grabbedstart",
            conditions = {
                { parameter = "hitType", conditionType = StateMachineCommon.EConditionType.Equal, value = 3 },
            }
        },
        {
            state = "ina_blocked",
            conditions = {
                { parameter = "hitType", conditionType = StateMachineCommon.EConditionType.Equal, value = 2 },
            }
        },
        {
            state = "ina_knockdownstart",
            conditions = {
                { parameter = "isDead", value = true },
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.001 },
            }
        },
        {
            state = "ina_knockdownstart",
            conditions = {
                { parameter = "hitType", conditionType = StateMachineCommon.EConditionType.Equal, value = 4 },
            }
        },
        {
            state = "ina_hita",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "ina_hita",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "ina_hits",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_washit, states.parameters)
    end,
}

-- Ina_PushBlock
states.ina_pushblock = {
    transitions = {
        {
            state = "ina_pushblocka",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "ina_pushblockc",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "ina_pushblocks",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.ina_pushblock, states.parameters)
    end,
}

return states
