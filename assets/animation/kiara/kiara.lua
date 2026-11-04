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
    ["hcf"] = StateMachineCommon.EParameterType.Trigger,
    ["exBars"] = StateMachineCommon.EParameterType.Int,
    ["hitConfirm"] = StateMachineCommon.EParameterType.Trigger,
    ["wasHit"] = StateMachineCommon.EParameterType.Trigger,
    ["hitStun"] = StateMachineCommon.EParameterType.Bool,
    ["isDead"] = StateMachineCommon.EParameterType.Bool,
    ["hitType"] = StateMachineCommon.EParameterType.Int,
    ["win"] = StateMachineCommon.EParameterType.Trigger,
    ["winFrame"] = StateMachineCommon.EParameterType.Int,
    ["parry"] = StateMachineCommon.EParameterType.Trigger,
    ["chargeH"] = StateMachineCommon.EParameterType.Trigger,
    ["chargeV"] = StateMachineCommon.EParameterType.Trigger,
}

states.defaultState = "kiara_default"
states.spriteAsset = "kiara_atlas"

states.any_state = {
    transitions = {
        {
            state = "kiara_washit",
            conditions = {
                { parameter = "wasHit" },
            }
        },
        {
            state = "kiara_burst",
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

states.kiara_default = {
    transitions = {
        {
            state = "kiara_airrise",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "kiara_idle",
            conditions = {}
        },
    },
    tick = function(self, actor, frame)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
}

states.kiara_idle = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle00")  end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle01")  end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle02")  end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle03")  end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle04")  end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle05")  end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle06")  end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle07")  end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle08")  end
    },
    transitions = {
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_crouchingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_winstart",
            conditions = {
                { parameter = "win" },
            }
        },
    },
    maxFrames = 45,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_idle00")
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

states.kiara_walkfstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite():SetSprite("kiara_walkf00")  end
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkf00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Walk)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "kiara_walkf"
        end
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end,
    transitions = {
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_walkf",
            minFrame = 6,
            conditions = {}
        },
    },
}

states.kiara_walkf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf01")  end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf02")  end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf03")  end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf04")  end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf05")  end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf06")  end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf07")  end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf08")  end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf09")  end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf10")  end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf11")  end
    },
    maxFrames = 55,
    transitions = {
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_walkfend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 1 },
            }
        },
        {
            state = "kiara_idle",
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
        actor:Sprite():SetSprite("kiara_walkf01")
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

states.kiara_walkbstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb00")  end
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkb00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.WalkBack)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if (frame >= self.maxFrames) then
            return "kiara_walkb"
        end
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end,
    transitions = {
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkb",
            minFrame = 6,
            conditions = {}
        },
    },
}

states.kiara_walkb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb01")  end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb02")  end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb03")  end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb04")  end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb05")  end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb06")  end,
        [27] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb07")  end,
        [31] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb08")  end,
        [38] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb09")  end,
        [42] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb10")  end,
        [46] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb11")  end
    },
    transitions = {
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkbend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = -1 },
            }
        },
        {
            state = "kiara_idle",
            conditions = {
                {
                    parameter = "hInput",
                    conditionType = StateMachineCommon.EConditionType.Greater,
                    value = -1
                }

            }
        },
    },
    maxFrames = 50,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkb01")
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

states.kiara_stand2crouch = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch00")  end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch01")  end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch02")  end
    },
    transitions = {
        {
            state = "kiara_crouch",
            minFrame = 6,
            conditions = {}
        },
        {
            state = "kiara_crouchingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_crouch2stand",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = -1 },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_crouch00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end,
    maxFrames = 5,
}

states.kiara_crouch2stand = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch03")  end
    },
    maxFrames = 4,
    transitions = {
        {
            state = "kiara_idle",
            minFrame = 5,
            conditions = {}
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
    onEnter = function(actor)

    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        if frame >= self.maxFrames then
            return "kiara_idle"
        end
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
}

states.kiara_hits = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hits00")  end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hits01")  end
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_hits00")
    end,
    tick = function(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end,
    maxFrames = 2,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
        {
            state = "kiara_hitsend",
            minFrame = 3,
            conditions = {}
        },
    },
}

states.kiara_hitc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hitc00")  end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hitc00")  end
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_hitc00")
    end,
    tick = function(self, actor, frame)
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end
}

states.kiara_hitarise = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita00")  end,
        [1] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita00")  end
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_hita00")
    end,
    tick = function(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end,
    maxFrames = 3,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_knockdown",
            conditions = {
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.1 },
            }
        },
        {
            state = "kiara_tech",
            conditions = {
                { parameter = "hitStun", value = false },
                { parameter = "button" },
            }
        },
        {
            state = "kiara_hitarise2fall",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
}

states.kiara_hitarise2fall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita02") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita03") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita04") end,
    },
    maxFrames = 8,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_hita02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_knockdown",
            conditions = {
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.1 },
            }
        },
        {
            state = "kiara_tech",
            conditions = {
                { parameter = "hitStun", value = false },
                { parameter = "button" },
            }
        },
        {
            state = "kiara_hitafall",
            minFrame = 9,
            conditions = {}
        },
    },
}

states.kiara_hitafall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita04") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita05") end,
    },
    maxFrames = 9,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_hita04")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_knockdown",
            conditions = {
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.1 },
            }
        },
        {
            state = "kiara_tech",
            conditions = {
                { parameter = "hitStun", value = false },
                { parameter = "button" },
            }
        },
    },
}

states.kiara_jump = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump00")  end
    },
    transitions = {
        {
            state = "kiara_airrise",
            minFrame = 4,
            conditions = {}
        },
        {
            state = "kiara_rise2fall",
            conditions = {
                {
                    parameter = "vVelocity",
                    conditionType = StateMachineCommon.EConditionType.Lesser,
                    value = 0
                }

            }
        },
        {
            state = "kiara_idle",
            conditions = {
                {
                    parameter = "inAir",
                    conditionType = StateMachineCommon.EConditionType.Equal,
                    value = 0
                }

            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_jump00")
        actor:Movement():Jump()
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    maxFrames = 3,
    onExit = function(actor)
    end,
}

states.kiara_rise2fall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump01")  end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump02")  end,
    },
    maxFrames = 6,
    transitions = {
        {
            state = "kiara_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_fall",
            minFrame = 7,
            conditions = {}
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_jump01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.kiara_fall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump03")  end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump04")  end
    },
    maxFrames = 6,
    transitions = {
        {
            state = "kiara_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_jump03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end

}

states.kiara_standingattack = {
    transitions = {
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hcf" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "heavy" },
                { parameter = "chargeH" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "medium" },
                { parameter = "chargeH" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "light" },
                { parameter = "chargeH" },
            }
        },
        {
            state = "kiara_grabstart",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "special" },
            }
        },
        {
            state = "kiara_sheavystart",
            conditions = {
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_smedium",
            conditions = {
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_slight",
            conditions = {
                { parameter = "light" },
            }
        },
        {
            state = "kiara_sheavy",
            conditions = {
                {
                    parameter = "heavy"
                }

            }
        },
        {
            state = "kiara_slight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_standingattack, states.parameters)
    end
}

states.kiara_slight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_slight00")  end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_slight01")  end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_slight02")  end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_slight03")  end
    },
    maxFrames = 16,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 17,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_cheavystart",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_cmedium",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
        {
            state = "kiara_sheavystart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_smedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_slightrestart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "light" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_slight00");
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "kiara_idle"
        end
    end,
    onExit = function(actor)
    end,
}

states.kiara_smedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium00")  end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium01")  end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium02")  end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium03")  end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium04")  end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium05")  end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium06")  end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_smedium07")  end
    },
    maxFrames = 28,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 29,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_cheavystart",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
        {
            state = "kiara_sheavystart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_smedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
        if frame >= self.maxFrames then
            return "kiara_idle"
        end
    end,
    onExit = function(actor)
    end,
}

states.kiara_sheavystart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy00")  end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy01")  end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy02")  end,
    },
    transitions = {
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
        {
            state = "kiara_sheavyhold",
            minFrame = 31,
            conditions = {}
        },
        {
            state = "kiara_sheavy",
            conditions = {
                {
                    parameter = "heavyHeld",
                    value = false
                }

            }
        },
    },
    maxFrames = 30,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "kiara_sheavyfull"
        end
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)

    end
}

states.kiara_sheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy03")  end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy04")  end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy05")  end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy06")  end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy07")  end,
    },
    maxFrames = 24,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sheavy03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        local nextState = StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
        if nextState then return nextState end
    end,
    onExit = function(actor)

    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 25,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
    },
}

states.kiara_sheavyfull = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy03") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy04") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy05") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy06") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy07") end,
    },
    maxFrames = 21,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sheavy03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 22,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
    },
}
-- Kiara_SWalkF / Kiara_SWalkF_End
states.kiara_walkfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf11") end,
    },
    maxFrames = 4,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkf11")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_idle",
            minFrame = 5,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
}

-- Kiara_SWalkB / Kiara_SWalkB_End
states.kiara_walkbend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb11") end,
    },
    maxFrames = 4,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkb11")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_idle",
            minFrame = 5,
            conditions = {}
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_stand2crouch",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_walkfstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
    },
}

-- Kiara_SDashF / Kiara_SDashF_Start
states.kiara_dashfstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf00") end,
    },
    maxFrames = 6,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_dashf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_dashf",
            minFrame = 7,
            conditions = {}
        },
    },
}

-- Kiara_SDashF / Kiara_SDashF
states.kiara_dashf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf02") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf03") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf04") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf05") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf06") end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf07") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf08") end,
    },
    maxFrames = 33,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_dashf01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_crouchingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_dashfend",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 1 },
            }
        },
    },
}

-- Kiara_SDashF / Kiara_SDashF_End
states.kiara_dashfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb04") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb05") end,
    },
    maxFrames = 11,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_dashb04")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 12,
            conditions = {}
        },
        {
            state = "kiara_walkbstart",
            conditions = {
                { parameter = "hInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
}

-- Kiara_SDashB / Kiara_SDashB
states.kiara_dashb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb02") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb03") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb02") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb04") end,
    },
    maxFrames = 18,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_dashb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 19,
            conditions = {}
        },
    },
}

-- Kiara_Win / Kiara_WinStart
states.kiara_winstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win04") end,
        [26] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win05") end,
        [32] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win06") end,
    },
    maxFrames = 41,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_win00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_win1start",
            minFrame = 42,
            conditions = {
                { parameter = "winFrame", conditionType = StateMachineCommon.EConditionType.Equal, value = 1 },
            }
        },
        {
            state = "kiara_win2start",
            minFrame = 42,
            conditions = {}
        },
    },
}

-- Kiara_Win1 / Kiara_Win1_Start
states.kiara_win1start = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win07") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win08") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win09") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win10") end,
    },
    maxFrames = 19,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_win07")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_win1",
            minFrame = 20,
            conditions = {}
        },
    },
}

-- Kiara_Win1 / Kiara_Win1_End
states.kiara_win1 = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win11") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win12") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win13") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win14") end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win15") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win16") end,
        [31] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win15") end,
        [37] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win16") end,
        [43] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win15") end,
        [49] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win16") end,
    },
    maxFrames = 50,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_win11")
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

-- Kiara_Win2 / Kiara_Win2_Start
states.kiara_win2start = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win17") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win18") end,
    },
    maxFrames = 11,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_win17")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_win2",
            minFrame = 12,
            conditions = {}
        },
    },
}

-- Kiara_Win2 / Kiara_Win2_End
states.kiara_win2 = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win19") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win20") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win21") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win22") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win23") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win24") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_win25") end,
    },
    maxFrames = 36,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_win19")
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

-- Kiara_AInAir / Kiara_ARising
states.kiara_airrise = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv09") end,
    },
    maxFrames = 4,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdv09")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
        {
            state = "kiara_rise2fall",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
    },
}

-- Kiara_AJump / Kiara_AJump
states.kiara_airjump = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv09") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdv09")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_airrise",
            minFrame = 4,
            conditions = {}
        },
    },
}

-- Kiara_ADashF / Kiara_ADashF
states.kiara_airdashf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf00") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_dashf00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_airdashfend",
            minFrame = 4,
            conditions = {}
        },
    },
}

-- Kiara_ADashF / Kiara_ADashF_End
states.kiara_airdashfend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_airdashfend00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_airdashfend01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_airdashfend00") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashf00") end,
    },
    maxFrames = 17,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_airdashfend00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 18,
            conditions = {}
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
}

-- Kiara_ADashB / Kiara_ADashB
states.kiara_airdashb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb01") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_dashb00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_airdashbend",
            minFrame = 4,
            conditions = {}
        },
    },
}

-- Kiara_ADashB / Kiara_ADashB_End
states.kiara_airdashbend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb02") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb03") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb02") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb03") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb02") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_dashb04") end,
    },
    maxFrames = 18,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_dashb02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 19,
            conditions = {}
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "button" },
            }
        },
    },
}

-- Kiara_CCrouch / Kiara_CCrouch
states.kiara_crouch = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch02") end,
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_crouch02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_crouchingattack",
            conditions = {
                { parameter = "button" },
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_crouch2stand",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = -1 },
            }
        },
    },
}

-- Kiara_SAtkHeavy / Kiara_SAtkHeavyHold
states.kiara_sheavyhold = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy02") end,
    },
    maxFrames = 20,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sheavy02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_sheavy",
            conditions = {
                { parameter = "heavyHeld", value = false },
            }
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
        {
            state = "kiara_sheavyfull",
            minFrame = 21,
            conditions = {}
        },
    },
}

-- Kiara_SAtkSpecial / Kiara_SSpecial
states.kiara_sspecial = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sspecial00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sspecial01") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh07") end,
    },
    maxFrames = 25,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sspecial00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_sspecialsuccess",
            conditions = {
                { parameter = "parry" },
            }
        },
        {
            state = "kiara_default",
            minFrame = 26,
            conditions = {}
        },
    },
}

-- Kiara_SAtkSpecialSuccess / Kiara_SSpecialSuccess
states.kiara_sspecialsuccess = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sspecial02") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sspecial03") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sspecial04") end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh07") end,
    },
    maxFrames = 14,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sspecial02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_sspecial",
            minFrame = 15,
            conditions = {
                { parameter = "special" },
            }
        },
        {
            state = "kiara_default",
            minFrame = 15,
            conditions = {}
        },
    },
}

-- Kiara_SGrabStart / Kiara_GrabStart
states.kiara_grabstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab01") end,
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sgrab00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_grab",
            conditions = {
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_grabmiss",
            minFrame = 6,
            conditions = {}
        },
    },
}

-- Kiara_SGrabMiss / Kiara_GrabWhiff
states.kiara_grabmiss = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab03") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab04") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab05") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab06") end,
    },
    maxFrames = 26,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sgrab03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 27,
            conditions = {}
        },
    },
}

-- Kiara_SGrabSuccess / Kiara_GrabSuccess
states.kiara_grab = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab01") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sgrab02") end,
    },
    maxFrames = 56,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sgrab01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 57,
            conditions = {}
        },
    },
}

-- Kiara_SAtkChargeV / Kiara_SAtkChargeV
states.kiara_chargevlight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv01") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv03") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv04") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv05") end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv06") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv07") end,
        [44] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv09") end,
    },
    maxFrames = 49,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdv00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 50,
            conditions = {}
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "button" },
            }
        },
    },
}

-- Kiara_SAtkChargeVMed / Kiara_SAtkChargeVMed
states.kiara_chargevmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv01") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv03") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv04") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv05") end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv06") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv07") end,
        [44] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv09") end,
    },
    maxFrames = 49,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdv00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 50,
            conditions = {}
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "button" },
            }
        },
    },
}

-- Kiara_SAtkChargeVEX / Kiara_SAtkChargeVEX
states.kiara_chargevex = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv01") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv03") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv04") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv05") end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv06") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv07") end,
        [44] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdv09") end,
    },
    maxFrames = 49,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdv00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 50,
            conditions = {}
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_airattack",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "button" },
            }
        },
    },
}

-- Kiara_SAtkChargeH / Kiara_SAtkChargeH
states.kiara_chargehlight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh01") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh02") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh03") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh04") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh05") end,
        [33] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh06") end,
        [38] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh07") end,
    },
    maxFrames = 41,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdh00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 42,
            conditions = {}
        },
    },
}

-- Kiara_SAtkChargeHMed / Kiara_SAtkChargeHMed
states.kiara_chargehmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh01") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh02") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh03") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh04") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh05") end,
        [33] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh06") end,
        [38] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh07") end,
    },
    maxFrames = 41,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdh00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 42,
            conditions = {}
        },
    },
}

-- Kiara_SAtkChargeHEX / Kiara_SAtkChargeHEX
states.kiara_chargehex = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh00") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh01") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh02") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh03") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh04") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh05") end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh06") end,
        [26] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh07") end,
    },
    maxFrames = 30,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_holdh00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 31,
            conditions = {}
        },
    },
}

-- Kiara_SAtkSuper / Kiara_SAtkSuper
states.kiara_ssuper = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst00") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst01") end,
        [125] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_superphoenix15") end,
        [131] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_superphoenix16") end,
        [135] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle00") end,
    },
    maxFrames = 143,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_burst00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 144,
            conditions = {}
        },
    },
}

-- Kiara_AAtkLight / Kiara_AAtkLight
states.kiara_alight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_alight00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_alight01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_alight02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_alight03") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_alight04") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_alight05") end,
    },
    maxFrames = 31,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_alight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "kiara_default",
            minFrame = 32,
            conditions = {}
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_amedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_aheavy",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
    },
}

-- Kiara_AAtkMedium / Kiara_AAtkMedium
states.kiara_amedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_amedium00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_amedium01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_amedium02") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_amedium03") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_amedium04") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_amedium05") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_amedium06") end,
    },
    maxFrames = 26,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_amedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "kiara_default",
            minFrame = 27,
            conditions = {}
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_alight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_aheavy",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
    },
}

-- Kiara_AAtkHeavy / Kiara_AAtkHeavy
states.kiara_aheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy01") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy02") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy03") end,
        [14] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy04") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy05") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy06") end,
        [37] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_aheavy07") end,
    },
    maxFrames = 43,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_aheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_idle",
            conditions = {
                { parameter = "inAir", value = false },
            }
        },
        {
            state = "kiara_default",
            minFrame = 44,
            conditions = {}
        },
        {
            state = "kiara_airjump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_airdashf",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_airdashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
    },
}

-- Kiara_ASpecial / Kiara_SSpecial
states.kiara_aspecial = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sspecial00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sspecial01") end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_holdh07") end,
    },
    maxFrames = 25,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_sspecial00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 26,
            conditions = {}
        },
    },
}

-- Kiara_CAtkLight / Kiara_CAtkLight
states.kiara_clight = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_clight00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_clight01") end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_clight02") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_clight03") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_clight04") end,
    },
    maxFrames = 20,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_clight00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_crouch",
            minFrame = 21,
            conditions = {}
        },
        {
            state = "kiara_crouchingattack",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "button" },
            }
        },
        {
            state = "kiara_standingattack",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "button" },
            }
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
    },
}

-- Kiara_CAtkMedium / Kiara_CAtkMedium
states.kiara_cmedium = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium00") end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium01") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium02") end,
        [13] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium03") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium04") end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium05") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium06") end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cmedium07") end,
    },
    maxFrames = 33,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_cmedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_crouch",
            minFrame = 34,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_cheavystart",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "special" },
            }
        },
        {
            state = "kiara_sheavystart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_smedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "medium" },
            }
        },
    },
}

-- Kiara_CAtkHeavy / Kiara_CAtkHeavyStart
states.kiara_cheavystart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy00") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy01") end,
    },
    maxFrames = 16,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_cheavy00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_cheavyhold",
            minFrame = 17,
            conditions = {}
        },
    },
}

-- Kiara_CAtkHeavy / Kiara_CAtkHeavyHold
states.kiara_cheavyhold = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy01") end,
    },
    maxFrames = 20,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_cheavy01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_cheavy",
            conditions = {
                { parameter = "heavyHeld", value = false },
            }
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
        {
            state = "kiara_cheavyfull",
            minFrame = 21,
            conditions = {}
        },
    },
}

-- Kiara_CAtkHeavy / Kiara_CAtkHeavyHoldHit
states.kiara_cheavyfull = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy02") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy03") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy04") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy05") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy06") end,
    },
    maxFrames = 21,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_cheavy02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_crouch",
            minFrame = 22,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
    },
}

-- Kiara_CAtkHeavyEarly / Kiara_CAtkHeavyEarlyHit
states.kiara_cheavy = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy02") end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy03") end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy04") end,
        [9] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy05") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_cheavy06") end,
    },
    maxFrames = 26,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_cheavy02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_crouch",
            minFrame = 27,
            conditions = {}
        },
        {
            state = "kiara_dashfstart",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleForward" },
            }
        },
        {
            state = "kiara_dashb",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "doubleBack" },
            }
        },
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "hcf" },
                { parameter = "light" },
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hitConfirm" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "chargeH" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_jump",
            conditions = {
                { parameter = "hitConfirm" },
                { parameter = "jump" },
            }
        },
    },
}

-- Kiara_Burst / Kiara_Burst
states.kiara_burst = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst00") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst01") end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst02") end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst00") end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst01") end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst02") end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_burst00") end,
    },
    maxFrames = 51,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_burst00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 52,
            conditions = {}
        },
    },
}

-- Kiara_HitS / Kiara_HitSEnd
states.kiara_hitsend = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hits01") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_hits01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
    },
}

-- Kiara_HitTech / Kiara_Tech
states.kiara_tech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_tech00") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_tech01") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_tech02") end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_tech03") end,
    },
    maxFrames = 26,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_tech00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 27,
            conditions = {}
        },
    },
}

-- Kiara_HitKnockdownStart / Kiara_Knockdown_Start
states.kiara_knockdownstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown00") end,
    },
    maxFrames = 6,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_knockdown00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_knockdown",
            minFrame = 7,
            conditions = {}
        },
    },
}

-- Kiara_HitKnockdown / Kiara_Knockdown
states.kiara_knockdown = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown01") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown02") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown03") end,
    },
    maxFrames = 26,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_knockdown01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_getup",
            minFrame = 27,
            conditions = {}
        },
    },
}

-- Kiara_HitKnockdown / Kiara_Knockdown_Getup
states.kiara_getup = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown04") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown05") end,
    },
    maxFrames = 9,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_knockdown04")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_dead",
            conditions = {
                { parameter = "isDead", value = true },
            }
        },
        {
            state = "kiara_crouch",
            minFrame = 10,
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_default",
            minFrame = 10,
            conditions = {}
        },
    },
}

-- Kiara_HitKnockdownDead / Kiara_Knockdown_Dead
states.kiara_dead = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown03") end,
    },
    maxFrames = 1,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_knockdown03")
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

-- Kiara_SWasGrabbed / Kiara_GrabbedByGura_Start
states.kiara_grabbedstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block00") end,
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_grabtech",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "kiara_grabbedend",
            minFrame = 6,
            conditions = {}
        },
    },
}

-- Kiara_SWasGrabbed / Kiara_GrabbedByGura_End
states.kiara_grabbedend = {
    onEnter = function(actor)
        local grabId = actor:Animator():GetInt("grabId") % 3
        if grabId == 0 then return "kiara_grabbedend_gura"
        elseif grabId == 1 then return "kiara_grabbedend_ina"
        else return "kiara_grabbedend_kiara" end
    end,
}

-- Kiara_SGrabTech / Kiara_GrabTech
states.kiara_grabtech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_grabtech00") end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_grabtech01") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_grabtech02") end,
    },
    maxFrames = 17,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_grabtech00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 18,
            conditions = {}
        },
    },
}

-- GrabBreak / Kiara_GrabBreak
states.kiara_grabbreak = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block00") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle00") end,
    },
    maxFrames = 17,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 18,
            conditions = {}
        },
    },
}

-- Kiara_HitBlockedC / Kiara_BlockC
states.kiara_blockc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block01") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_pushblock",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "kiara_crouch",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
    },
}

-- Kiara_HitBlockedA / Kiara_BlockA
states.kiara_blocka = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block02") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_pushblock",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "kiara_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
    },
}

-- Kiara_HitBlockedS / Kiara_BlockS
states.kiara_blocks = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block00") end,
    },
    maxFrames = 3,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_pushblock",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "kiara_default",
            conditions = {
                { parameter = "hitStun", value = false },
            }
        },
    },
}

-- Kiara_PushBlockA / Kiara_PushblockA
states.kiara_pushblocka = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block02") end,
    },
    maxFrames = 16,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block02")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 17,
            conditions = {}
        },
    },
}

-- Kiara_PushBlockC / Kiara_PushblockC
states.kiara_pushblockc = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block01") end,
    },
    maxFrames = 16,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 17,
            conditions = {}
        },
    },
}

-- Kiara_PushBlockS / Kiara_PushblockS
states.kiara_pushblocks = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block00") end,
    },
    maxFrames = 16,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 17,
            conditions = {}
        },
    },
}

-- Kiara_SWasGrabbed / Kiara_GrabbedByGura_End
states.kiara_grabbedend_gura = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block00") end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown00") end,
        [17] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_knockdown03") end,
    },
    maxFrames = 42,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 43,
            conditions = {}
        },
    },
}

-- Kiara_SWasGrabbed / Kiara_GrabbedByIna_End
states.kiara_grabbedend_ina = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_block00") end,
    },
    maxFrames = 45,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_block00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 46,
            conditions = {}
        },
    },
}

-- Kiara_SWasGrabbed / Kiara_GrabbedByKiara_End
states.kiara_grabbedend_kiara = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hits00") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_hita01") end,
    },
    maxFrames = 60,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_hits00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters, frame)
    end,
    onExit = function(actor)
    end,
    transitions = {
        {
            state = "kiara_default",
            minFrame = 61,
            conditions = {}
        },
    },
}

-- Kiara_SAtkChargeHEXTrans
states.kiara_chargehexcheck = {
    transitions = {
        {
            state = "kiara_chargehex",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_chargehexcheck, states.parameters)
    end,
}

-- Kiara_SAtkChargeVEXTrans
states.kiara_chargevexcheck = {
    transitions = {
        {
            state = "kiara_chargevex",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_chargevexcheck, states.parameters)
    end,
}

-- Kiara_Blocked
states.kiara_blocked = {
    transitions = {
        {
            state = "kiara_blocka",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "kiara_blockc",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_blocks",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_blocked, states.parameters)
    end,
}

-- Kiara_WasHit
states.kiara_washit = {
    transitions = {
        {
            state = "kiara_grabbedstart",
            conditions = {
                { parameter = "hitType", conditionType = StateMachineCommon.EConditionType.Equal, value = 3 },
            }
        },
        {
            state = "kiara_blocked",
            conditions = {
                { parameter = "hitType", conditionType = StateMachineCommon.EConditionType.Equal, value = 2 },
            }
        },
        {
            state = "kiara_knockdownstart",
            conditions = {
                { parameter = "isDead", value = true },
                { parameter = "inAir", value = false },
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0.001 },
            }
        },
        {
            state = "kiara_knockdownstart",
            conditions = {
                { parameter = "hitType", conditionType = StateMachineCommon.EConditionType.Equal, value = 4 },
            }
        },
        {
            state = "kiara_hitarise",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "kiara_hitarise",
            conditions = {
                { parameter = "vVelocity", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 },
            }
        },
        {
            state = "kiara_hits",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_washit, states.parameters)
    end,
}

-- Kiara_CrouchingAttack
states.kiara_crouchingattack = {
    transitions = {
        {
            state = "kiara_ssuper",
            conditions = {
                { parameter = "exBars", conditionType = StateMachineCommon.EConditionType.Greater, value = 1 },
                { parameter = "hcf" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargevexcheck",
            conditions = {
                { parameter = "chargeV" },
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_chargevmedium",
            conditions = {
                { parameter = "chargeV" },
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_chargevlight",
            conditions = {
                { parameter = "chargeV" },
                { parameter = "light" },
            }
        },
        {
            state = "kiara_chargehexcheck",
            conditions = {
                { parameter = "heavy" },
                { parameter = "chargeH" },
            }
        },
        {
            state = "kiara_chargehmedium",
            conditions = {
                { parameter = "medium" },
                { parameter = "chargeH" },
            }
        },
        {
            state = "kiara_chargehlight",
            conditions = {
                { parameter = "light" },
                { parameter = "chargeH" },
            }
        },
        {
            state = "kiara_grabstart",
            conditions = {
                { parameter = "grab" },
            }
        },
        {
            state = "kiara_sspecial",
            conditions = {
                { parameter = "special" },
            }
        },
        {
            state = "kiara_cheavystart",
            conditions = {
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_cmedium",
            conditions = {
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_clight",
            conditions = {
                { parameter = "light" },
            }
        },
        {
            state = "kiara_clight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_crouchingattack, states.parameters)
    end,
}

-- Kiara_AirAttack
states.kiara_airattack = {
    transitions = {
        {
            state = "kiara_aspecial",
            conditions = {
                { parameter = "special" },
            }
        },
        {
            state = "kiara_aheavy",
            conditions = {
                { parameter = "heavy" },
            }
        },
        {
            state = "kiara_amedium",
            conditions = {
                { parameter = "medium" },
            }
        },
        {
            state = "kiara_alight",
            conditions = {
                { parameter = "light" },
            }
        },
        {
            state = "kiara_alight",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_airattack, states.parameters)
    end,
}

-- Kiara_PushBlock
states.kiara_pushblock = {
    transitions = {
        {
            state = "kiara_pushblocka",
            conditions = {
                { parameter = "inAir", value = true },
            }
        },
        {
            state = "kiara_pushblockc",
            conditions = {
                { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Lesser, value = 0 },
            }
        },
        {
            state = "kiara_pushblocks",
            conditions = {}
        },
    },
    onEnter = function(actor)
        return StateMachineCommon.evaluateTransitions(actor, states.kiara_pushblock, states.parameters)
    end,
}

-- Restart the attack through a separate entry state.
states.kiara_slightrestart = {
    onEnter = function(actor)
        return "kiara_slight"
    end
}

return states
