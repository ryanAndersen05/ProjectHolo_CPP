local common = require("assets.animation.statemachine")

for _, characterName in ipairs({"kiara", "ina"}) do
    local states = require("assets.animation." .. characterName .. "." .. characterName)
    local function actor(initial)
        local value = { values = {}, frame = 0, sprites = {}, jumps = 0 }
        for name, kind in pairs(states.parameters) do
            if kind == 1 or kind == 4 then value.values[name] = false else value.values[name] = 0 end
        end
        for name, initialValue in pairs(initial or {}) do value.values[name] = initialValue end
        local animator = {}
        function animator:GetBool(name)
            assert(states.parameters[name], "Unknown bool: " .. name)
            return value.values[name]
        end
        function animator:GetInt(name)
            assert(states.parameters[name], "Unknown int: " .. name)
            return value.values[name]
        end
        function animator:GetFloat(name)
            assert(states.parameters[name], "Unknown float: " .. name)
            return value.values[name]
        end
        function animator:ResetTrigger(name) value.values[name] = false end
        local sprite = {}
        function sprite:SetSprite(name)
            assert(name == "" or characterSprites[characterName][name], "Missing atlas sprite: " .. name)
            value.sprites[#value.sprites + 1] = name
        end
        local movement = {}
        function movement:SetMovement(kind) value.movement = kind end
        function movement:Jump() value.jumps = value.jumps + 1 end
        function value:Animator() return animator end
        function value:Sprite() return sprite end
        function value:Movement() return movement end
        return value
    end
    local function enter(value, name)
        if name == value.state then return end
        for _ = 1, 32 do
            local previous = value.state and states[value.state]
            if previous and previous.onExit then previous.onExit(value) end
            assert(states[name], "Unknown state: " .. tostring(name))
            value.state, value.frame = name, 0
            local definition = states[name]
            name = definition.onEnter and definition.onEnter(value)
            if not name then return end
        end
        error("Recursive state routing")
    end
    local function tick(value)
        local definition = states[value.state]
        local nextState = states.any_state.tick(states.any_state, value, value.frame)
        if not nextState and definition.tick then nextState = definition.tick(definition, value, value.frame) end
        if nextState then enter(value, nextState) else value.frame = value.frame + 1 end
    end
    local function expect(value, suffix) assert(value.state == characterName .. "_" .. suffix, value.state .. " expected " .. suffix) end

    local count = 0
    for name, definition in pairs(states) do
        if type(definition) == "table" then
            for key, transition in pairs(definition.transitions or {}) do
                assert(type(key) == "number", "Transitions must remain ordered arrays")
                assert(states[transition.state], "Missing target " .. transition.state)
                for _, condition in ipairs(transition.conditions) do
                    assert(states.parameters[condition.parameter], "Missing condition parameter")
                end
            end
            if definition.keyFrames then
                count = count + 1
                if definition.maxFrames then assert(definition.maxFrames > 0, "Invalid duration: " .. name) end
                local sample = actor({hitStun = true, inAir = true, vVelocity = 1})
                enter(sample, name)
                -- Execute every authored keyframe directly, including otherwise unreachable effects.
                for frame, callback in pairs(definition.keyFrames) do callback(sample) end
                -- Exercise real ticks separately, allowing routing and normal callbacks.
                for _ = 1, 180 do tick(sample) end
            end
        end
    end
    assert(count >= 65, "Missing animation phases")

    local grounded, airborne = actor(), actor({inAir = true, vVelocity = 1})
    enter(grounded, states.defaultState); enter(airborne, states.defaultState)
    tick(grounded); tick(airborne)
    expect(grounded, "idle"); expect(airborne, "airrise")
    assert(grounded.frame == 0 and airborne.frame == 0, "Entry frame was skipped")

    local idle = actor({hInput = 1})
    enter(idle, characterName .. "_idle"); tick(idle)
    expect(idle, "walkfstart")
    for _ = 1, 20 do tick(idle) end
    expect(idle, "walkf")
    assert(idle.movement == common.EMovementType.Walk, "Existing walk callback was lost")
    idle.values.hInput = 0; tick(idle)
    expect(idle, "walkfend")
    for _ = 1, 20 do tick(idle) end
    expect(idle, "idle")

    local jumping = actor()
    enter(jumping, characterName .. "_jump")
    assert(jumping.jumps == 1, "Existing jump callback was lost")

    local hit = actor({wasHit = true, hitType = 2, button = true, hitStun = true})
    enter(hit, characterName .. "_idle"); tick(hit)
    expect(hit, "blocks")
    assert(not hit.values.wasHit and hit.values.button, "Global transition consumed unrelated input")
    hit.values.burst, hit.values.blockBurst = true, true
    tick(hit); expect(hit, "blocks")
    hit.values.blockBurst = false; tick(hit); expect(hit, "burst")
    assert(not hit.values.burst)

    local dash = actor({hInput = 1, button = true, medium = true, vInput = -1})
    enter(dash, characterName .. "_dashfstart"); tick(dash)
    expect(dash, "dashfstart")
    assert(dash.values.button, "Clip-gated transition consumed input during startup")
    for _ = 1, 20 do tick(dash) end
    expect(dash, "cmedium")

    for index, suffix in ipairs({"gura", "ina", "kiara"}) do
        local grabbed = actor({grabId = index - 1})
        enter(grabbed, characterName .. "_grabbedend")
        expect(grabbed, "grabbedend_" .. suffix)
        grabbed.values.grabId = (index + 1) % 3
        tick(grabbed); expect(grabbed, "grabbedend_" .. suffix)
    end

    if characterName == "kiara" then
        local super = actor({exBars = 2, hcf = true, light = true, heavy = true})
        enter(super, "kiara_standingattack"); expect(super, "ssuper")
        assert(not super.values.hcf and not super.values.light and super.values.heavy)
        local charge = actor({chargeV = true, heavy = true, exBars = 0})
        enter(charge, "kiara_standingattack"); expect(charge, "chargevmedium")
        charge = actor({chargeH = true, heavy = true, exBars = 1})
        enter(charge, "kiara_standingattack"); expect(charge, "chargehex")
        -- The existing release/fully-charged behavior and timings stay in place.
        local heavy = actor({heavyHeld = false})
        enter(heavy, "kiara_sheavystart"); tick(heavy); expect(heavy, "sheavy")
        local win = actor({winFrame = 1})
        enter(win, "kiara_winstart")
        for _ = 1, 43 do tick(win) end
        expect(win, "win1start")
    else
        local super = actor({exBars = 2, doubleQcf = true, light = true, special = true})
        enter(super, "ina_standingattack"); expect(super, "ssuper")
        assert(not super.values.doubleQcf and not super.values.light and super.values.special)
        local spell = actor({qcf = true, heavy = true, exBars = 0})
        enter(spell, "ina_standingattack"); expect(spell, "qcfmedium")
        spell = actor({qcb = true, heavy = true, exBars = 1})
        enter(spell, "ina_standingattack"); expect(spell, "qcbex")
        local followup = actor({light = true})
        enter(followup, "ina_slight"); tick(followup); expect(followup, "slightfollowup")
        assert(states.ina_slight.keyFrames[19] and states.ina_slight.maxFrames == 24, "Existing light timing changed")
    end
    print(characterName .. " graph, playback, priority, callbacks and sprite checks passed")
end
