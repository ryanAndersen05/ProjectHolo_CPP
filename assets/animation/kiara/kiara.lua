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

states.defaultState = "kiara_default"
states.spriteAsset = "kiara_atlas"

states.kiara_default = {
    onEnter = function(actor)
        return "kiara_idle"
    end
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
        ["kiara_jump"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = 0
            }
        },
        ["kiara_standingattack"] = {
            {
                parameter = "button"
            }

        },
        ["kiara_walkfstart"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = 0
            }
        },
        ["kiara_walkbstart"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        },
        ["kiara_stand2crouch"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            },
        },
    },
    maxFrames = 45,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_idle00")
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
        if frame >= self.maxFrames then
            return "kiara_walkf"
        end
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
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
        ["kiara_jump"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = 0
            }
        },
        ["kiara_stand2crouch"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        },
        ["kiara_idle"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 1
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite():SetSprite("kiara_walkf01")
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
        if (frame >= self.maxFrames) then
            return "kiara_walkb"
        end
    end,
    onExit = function(actor)
        actor:Movement():SetMovement(StateMachineCommon.EMovementType.None)
    end
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
        ["kiara_jump"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = 0
            }
        },
        ["kiara_stand2crouch"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        },
        ["kiara_idle"] = {
            {
                parameter = "hInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = -1
            }
        }
    },
    maxFrames = 50,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkb01")
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

states.kiara_stand2crouch = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch00")  end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch01")  end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch02")  end
    },
    transitions = {
        ["kiara_crouch2stand"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Greater,
                value = -1
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_crouch00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
    end,
    onExit = function(actor)

    end
}

states.kiara_crouch2stand = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_crouch03")  end
    },
    maxFrames = 4,
    transitions = {
        ["kiara_stand2crouch"] = {
            {
                parameter = "vInput",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        }
    },
    onEnter = function(actor)
        
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        if frame >= self.maxFrames then
            return "kiara_idle"
        end
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
    end
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
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end
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
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("")  end,
        [1] = function(actor) actor:Sprite("sprite"):SetSprite("")  end
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("")
    end,
    tick = function(self, actor, frame)
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
    end
}

states.kiara_hitarise2fall = {

}

states.kiara_hitafall = {

}

states.kiara_jump = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump00")  end
    },
    transitions = {
        ["kiara_rise2fall"] = {
            {
                parameter = "vVelocity",
                conditionType = StateMachineCommon.EConditionType.Lesser,
                value = 0
            }
        },
        ["kiara_idle"] = {
            {
                parameter = "inAir",
                conditionType = StateMachineCommon.EConditionType.Equal,
                value = 0
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_jump00")
        actor:Movement():Jump()
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
    end
}

states.kiara_rise2fall = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump01")  end,
        [3] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_jump02")  end,
    },
    maxFrames = 6,
    transitions = {
        ["kiara_idle"] = {
            {
                parameter = "inAir",
                value = false
            }
        }
    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_jump01")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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
    transitions = states.kiara_rise2fall.transitions,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_jump03")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, true)
        return StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
    end,
    onExit = function(actor)

    end

}

states.kiara_standingattack = {
    transitions = {
        ["kiara_sheavy"] = {
            {
                parameter = "heavy"
            }
        },
        ["kiara_smedium"] = {
            {
                parameter = "medium"
            }
        },
        ["kiara_slight"] = {
            {
                parameter = "light"
            }
        },
        ["kiara_sspecial"] = {
            {
                parameter = "special"
            }
        },
        ["kiara_slight"] = {} --fallthrough states
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_slight00");
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame, false)
        if frame >= self.maxFrames then
            return "kiara_idle"
        end
    end
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

    },
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_smedium00")
    end,
    tick = function(self, actor, frame)
        StateMachineCommon.tickState(self, actor, frame)
        if frame >= self.maxFrames then
            return "kiara_idle"
        end
    end
}

states.kiara_sheavystart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy00")  end,
        [2] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy01")  end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_sheavy02")  end,
    },
    transitions = {
        ["kiara_sheavy"] = {
            {
                parameter = "heavyHeld",
                value = false
            }
        }
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
        StateMachineCommon.evaluateTransitions(actor, self, states.parameters)
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
    end,
    onExit = function(actor)

    end
}

states.kiara_sheavyfull = {

}
return states