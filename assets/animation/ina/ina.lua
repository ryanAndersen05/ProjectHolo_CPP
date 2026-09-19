local states = {}

local StateMachineCommon = require("assets.animation.statemachine")

states.parameters = {
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
}

states.defaultState = "ina_default"
states.spriteAsset = "ina_atlas"

states.ina_default = {
    onEnter = function(actor)
        return "ina_idle"
    end
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
        ["ina_stand2crouch"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        },
        ["ina_walkf"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = 0
            }
        },
        ["ina_walkb"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        },
        ["ina_standingattack"] = {
            {
                parameter = "button"
            }
        }
    },
    maxFrames = 56,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_idle00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Idle)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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
        ["ina_idle"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 1
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_walkf00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Walk)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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
        ["ina_idle"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = -1
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_walkb00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.WalkBack)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashf00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Dash)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_dashb00")
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.Dash)
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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
        ["ina_crouch2stand"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = -1
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_crouch00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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
        ["ina_stand2crouch"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_crouch03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        if frame >= self.maxFrames then
            return "ina_idle"
        end
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump00")
        actor:Movement():Jump()
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_jump03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hits00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_hita00")
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

states.ina_blocks = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_blocks02") end
    },
    maxFrames = 15,
    transitions = {

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_blocks00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
    end,
    onExit = function(actor)

    end
}

states.ina_standingattack = {
    transitions = {
        ["ina_sheavy"] = {
            {
                parameter = "heavy"
            }
        },
        ["ina_smedium"] = {
            {
                parameter = "medium"
            }
        },
        ["ina_slight"] = {
            {
                parameter = "light"
            }
        },
        ["ina_sspecial"] = {
            {
                parameter = "special"
            }
        },
        ["ina_slight"] = {} --fallthrough states
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
        ["ina_slightfollowup"] = {
            {
                parameter = "light"
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_slight00")
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

states.ina_slightfollowup = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight04") end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight05") end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight06") end,
        [16] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight07") end,
        [22] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight08") end,
        [29] = function(actor) actor:Sprite("sprite"):SetSprite("ina_slight09") end
    },
    transitions = {},
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_slight04")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_smedium01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_sheavy00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_sspecial00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_ssuper00")
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

states.ina_crouchingattack = {
    transitions = {
        ["ina_cheavy"] = {
            {
                parameter = "heavy"
            }
        },
        ["ina_cmedium"] = {
            {
                parameter = "medium"
            }
        },
        ["ina_clight"] = {
            {
                parameter = "light"
            }
        },
        ["ina_sspecial"] = {
            {
                parameter = "special"
            }
        },
        ["ina_clight"] = {} --fallthrough state
    }
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_clight00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_cmedium00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_cheavy00")
        actor:Sprite("altSprite"):SetSprite("")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
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
        ["ina_aheavy"] = {
            {
                parameter = "heavy"
            }
        },
        ["ina_amedium"] = {
            {
                parameter = "medium"
            }
        },
        ["ina_alight"] = {
            {
                parameter = "light"
            }
        },
        ["ina_aspecial"] = {
            {
                parameter = "special"
            }
        },
        ["ina_alight"] = { } --Fallthrough state
    }
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_alight00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_aheavy00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcf00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_qcb00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_grab00")
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

states.ina_grabtech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_grabtech03") end
    },
    maxFrames = 20,
    transitions = {

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_grabtech00")
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

states.ina_tech = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech00") end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech01") end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech02") end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("ina_tech03") end
    },
    maxFrames = 20,
    transitions = {

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_tech00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_knockdown00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_burst00")
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("ina_win00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
    end,
    onExit = function(actor)

    end
}

return states
