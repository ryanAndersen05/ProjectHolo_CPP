local StateMachineCommon = {}

StateMachineCommon.EParameterType = {
    Bool =      1,
    Int =       2,
    Float =     3,
    Trigger =   4
}


StateMachineCommon.EConditionType = {
    Equal =     1,
    NotEqual =  2,
    Greater =   3,
    Lesser =    4,
}

StateMachineCommon.EMovementType = {
    None =      0,
    Idle =      1,
    Walk =      2,
    WalkBack =  3,
    Dash =      4,
}

StateMachineCommon.tickState = function(self, actor, frame, isLooping)
    local keyFrames = self["keyFrames"]
    local adjustedFrame = frame
    isLooping = isLooping or false
    if isLooping then
        adjustedFrame = frame % self["maxFrames"]
    end
    local event = keyFrames[adjustedFrame]
    if event then
        event(actor)
    end
end

StateMachineCommon.validateBool = function(actor, parameter, value)
    local actorValue = actor:Animator():GetBool(parameter)
    return value == actorValue
end

StateMachineCommon.validateInt = function(actor, parameter, conditionType, value)
    local actorValue = actor:Animator():GetInt(parameter)
    if conditionType == StateMachineCommon.EConditionType.Equal then
        return actorValue == value
    elseif conditionType == StateMachineCommon.EConditionType.NotEqual then
        return actorValue ~= value
    elseif conditionType == StateMachineCommon.EConditionType.Greater then
        return actorValue > value;
    elseif conditionType == StateMachineCommon.EConditionType.Lesser then
        return actorValue < value
    else
        print ("validateInt() - Invalid conditionType")
        return false
    end
end

StateMachineCommon.validateFloat = function(actor, parameter, conditionType, value)
    local actorValue = actor:Animator():GetFloat(parameter)
    if conditionType == StateMachineCommon.EConditionType.Greater then
        return actorValue > value
    elseif conditionType == StateMachineCommon.EConditionType.Lesser then
        return actorValue < value
    else
        print ("validateFloat() - Unsupported conditionType for Float Type")
        return false
    end
end

StateMachineCommon.validateConditions = function(actor, parameters, conditions)
    for _, condition in ipairs(conditions) do
        local parameterType = parameters[condition.parameter]
        if not parameterType then
            print ("validateConditions() - Invalid parameter passed in")
            return false
        end
        if parameterType == StateMachineCommon.EParameterType.Bool then
            if not StateMachineCommon.validateBool(actor, condition.parameter, condition.value) then
                return false
            end
        elseif parameterType == StateMachineCommon.EParameterType.Int then
            if not StateMachineCommon.validateInt(actor, condition.parameter, condition.conditionType, condition.value) then
                return false
            end
        elseif parameterType == StateMachineCommon.EParameterType.Float then
            if not StateMachineCommon.validateFloat(actor, condition.parameter, condition.conditionType, condition.value) then
                return false
            end
        elseif parameterType == StateMachineCommon.EParameterType.Trigger then
            if not StateMachineCommon.validateBool(actor, condition.parameter, true) then
                return false
            end
        end
    end
    return true
end

local function consumeTriggers(actor, parameters, conditions)
    for _, condition in ipairs(conditions) do
        if parameters[condition.parameter] == StateMachineCommon.EParameterType.Trigger then
            actor:Animator():ResetTrigger(condition.parameter)
        end
    end
end

StateMachineCommon.evaluateTransitions = function(actor, state, parameters, frame)
    local transitions = state.transitions
    if not transitions then return nil end
    for _, transition in ipairs(transitions) do
        local conditions = transition.conditions or {}
        if (not transition.minFrame or (frame and frame >= transition.minFrame))
            and StateMachineCommon.validateConditions(actor, parameters, conditions) then
            consumeTriggers(actor, parameters, conditions)
            return transition.state
        end
    end
    return nil
end

return StateMachineCommon
