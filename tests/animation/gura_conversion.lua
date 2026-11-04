local states = dofile("assets/animation/gura/gura.lua")
local function expect(value, message) assert(value, message or "Gura conversion check failed") end

local function actor(initial, parameterTypes)
    parameterTypes = parameterTypes or states.parameters
    local result = { values = {}, sprites = {}, resets = {}, frame = 0 }
    for name, kind in pairs(parameterTypes) do
        if kind == 1 or kind == 4 then result.values[name] = false else result.values[name] = 0 end
    end
    for name, value in pairs(initial or {}) do result.values[name] = value end
    local animator = {}
    function animator:GetBool(name) expect(parameterTypes[name], "Unknown parameter " .. name); return result.values[name] end
    function animator:GetInt(name) expect(parameterTypes[name], "Unknown parameter " .. name); return result.values[name] end
    function animator:GetFloat(name) expect(parameterTypes[name], "Unknown parameter " .. name); return result.values[name] end
    function animator:ResetTrigger(name) result.values[name] = false; result.resets[name] = (result.resets[name] or 0) + 1 end
    local sprite = {}
    function sprite:SetSprite(name)
        expect(name == "" or validSprites[name], "Missing current atlas sprite: " .. name)
        result.sprites[#result.sprites + 1] = name
    end
    function result:Animator() return animator end
    function result:Sprite() return sprite end
    local movement = {}
    function movement:SetMovement(value) result.movement = value end
    function movement:Jump() result.jumps = (result.jumps or 0) + 1 end
    function result:Movement() return movement end
    return result
end

local function enter(target, name)
    if target.state == name then return end -- Matches the C++ same-state guard.
    for _ = 1, 30 do
        local definition = states[name]
        expect(definition, "Missing state: " .. tostring(name))
        target.state, target.frame = name, 0
        local nextState = definition.onEnter and definition.onEnter(target)
        if not nextState then return end
        name = nextState
    end
    error("Recursive state entry")
end
local function tick(target)
    local definition = states[target.state]
    local anyState = states.any_state
    local nextState = anyState and anyState.tick and anyState.tick(anyState, target, target.frame)
    if not nextState then nextState = definition.tick and definition.tick(definition, target, target.frame) end
    if nextState then enter(target, nextState) else target.frame = target.frame + 1 end
end
local function run(target, count) for _ = 1, count do tick(target) end end
local function isState(target, name) return target.state == name end

-- The character remains ordinary editable Lua: explicit keyframes, transitions, and hooks.
expect(states.sourceStates == nil, "Generated source-schema data should not be the runtime format")
expect(states.parameters.light == 4 and states.parameters.lightHeld == 1, "Held and pressed inputs were conflated")
expect(states.parameters.vVelocity == 3 and states.parameters.hInput == 2, "Legacy enum mapping was incorrect")
local playbackStates = 0
for name, definition in pairs(states) do
    if type(definition) == "table" and definition.keyFrames then
        playbackStates = playbackStates + 1
        expect(definition.maxFrames > 0, "Missing authored animation duration")
        expect(definition.onEnter and definition.tick and definition.onExit, "Missing editable state hooks")
        for _, transition in ipairs(definition.transitions or {}) do
            expect(states[transition.state], "Unresolved transition target: " .. transition.state)
            for _, condition in ipairs(transition.conditions) do expect(states.parameters[condition.parameter], "Unmapped condition") end
        end
    end
end
expect(playbackStates >= 50, "Missing Gura animation states")

local first, second = actor(), actor({ inAir = true, vVelocity = 2 })
enter(first, states.defaultState); enter(second, states.defaultState)
tick(first); tick(second)
expect(isState(first, "gura_idle"), "Default ground routing failed")
expect(isState(second, "gura_airrise"), "Default air routing failed")
first.values.hInput = 1
tick(first)
expect(isState(first, "gura_walkfstart"), "Forward walk transition failed")
run(first, 12)
expect(isState(first, "gura_walkf"), "Walk did not reach its looping state")
run(first, 100)
expect(isState(first, "gura_walkf"), "Held walk exited its loop")
first.values.hInput = 0
tick(first)
expect(isState(first, "gura_walkfend"), "Walk release did not enter recovery")
run(first, 12)
expect(isState(first, "gura_idle"), "Walk exit time failed")
expect(second.frame == 0 and isState(second, "gura_airrise"), "Playback leaked between actor instances")

-- The source's priority is visible in array order, including routes with repeated destinations.
enter(first, "gura_idle")
first.values.vInput, first.values.button, first.values.light = -1, true, true
tick(first)
expect(isState(first, "gura_stand2crouch"), "Source transition priority was lost")
expect(first.values.button and first.values.light, "Unselected rule consumed attack triggers")
first.values.vInput = 0
enter(first, "gura_standingattack")
expect(isState(first, "gura_slight"), "Standing attack routing failed")
expect(not first.values.light, "Selected attack did not consume its trigger")
first.values.light, first.values.hitConfirm = true, true
tick(first)
expect(isState(first, "gura_slight") and first.frame == 0, "Same-state light cancel did not restart playback")

first.values.wasHit, first.values.hitType = true, 2
first.values.button = true
tick(first)
expect(isState(first, "gura_blocks"), "Any-state hit/block routing failed")
expect(not first.values.wasHit and first.values.button, "Interrupt consumed unrelated triggers")
first.values.burst, first.values.blockBurst, first.values.hitStun = true, true, true
tick(first)
expect(isState(first, "gura_blocks"), "BlockBurst condition ignored")
first.values.blockBurst = false
tick(first)
expect(isState(first, "gura_burst") and not first.values.burst, "Global burst transition failed")

local special = actor({ exBars = 0, qcb = true, heavy = true, light = true })
enter(special, "gura_standingattack")
expect(isState(special, "gura_rollmedium"), "EX route did not fall back when meter was empty")
expect(not special.values.qcb and not special.values.heavy and special.values.light,
    "Resource routing consumed the wrong input triggers")
local super = actor({ exBars = 2, grab = true, qcf = true, light = true })
enter(super, "gura_standingattack")
expect(isState(super, "gura_super"), "Super attack lost priority to a normal attack")
local launched = actor({ wasHit = true, hitType = 0, inAir = false, vVelocity = 1 })
enter(launched, "gura_idle")
tick(launched)
expect(isState(launched, "gura_hitrise"), "Duplicate-destination velocity routing branch was lost")

-- Startup and the cancelable loop are visible states, rather than hidden clip indices.
local dash = actor({ hInput = 1, button = true, medium = true })
enter(dash, "gura_dashfstart")
tick(dash)
expect(isState(dash, "gura_dashfstart"), "Dash canceled before its loop")
expect(dash.values.button, "Gated transition consumed a trigger too early")
run(dash, 20)
expect(isState(dash, "gura_smedium"), "Dash loop cancel did not activate")

local grabbed = actor({ grabId = 2 })
enter(grabbed, "gura_grabbedstart")
run(grabbed, 8)
expect(isState(grabbed, "gura_grabbedend_kiara"), "Grab recovery was not selected")
grabbed.values.grabId = 0
tick(grabbed)
expect(isState(grabbed, "gura_grabbedend_kiara"), "Selected grab recovery changed during playback")

-- Exercise actual callback keyframes against the current atlas for every authored animation state.
for name, definition in pairs(states) do
    if type(definition) == "table" and definition.keyFrames then
        local sample = actor({ hitStun = true, inAir = true, vVelocity = 1 })
        enter(sample, name)
        run(sample, 180)
    end
end
-- Every character uses arrays, with fallback entries after conditional choices.
local common = require("assets.animation.statemachine")
local ina = require("assets.animation.ina.ina")
local kiara = require("assets.animation.kiara.kiara")
for _, character in ipairs({ina, kiara}) do
    for name, definition in pairs(character) do
        if type(definition) == "table" and definition.transitions then
            for key, transition in pairs(definition.transitions) do
                expect(type(key) == "number" and type(transition.state) == "string", "Unconverted keyed transition: " .. name)
                expect(type(transition.conditions) == "table", "Missing transition conditions")
            end
        end
    end
    local ready = actor({ special = true }, character.parameters)
    local route = character.ina_standingattack or character.kiara_standingattack
    expect(common.evaluateTransitions(ready, route, character.parameters) == (character.ina_standingattack and "ina_sspecial" or "kiara_sspecial"),
        "Unconditional fallback overrode an attack input")
end
local compatibility = actor({ light = true })
local ordered = { transitions = {
    { state = "gura_win", minFrame = 3, conditions = { { parameter = "light" } } },
    { state = "gura_idle", conditions = {} }
} }
compatibility.values.light = true
expect(common.evaluateTransitions(compatibility, ordered, states.parameters, 2) == "gura_idle", "Frame gate was ignored")
expect(compatibility.values.light, "A gated transition consumed its trigger")
expect(common.evaluateTransitions(compatibility, ordered, states.parameters, 3) == "gura_win", "Array priority was lost")
expect(not compatibility.values.light, "Selected ordered transition did not consume its trigger")
print("Readable Gura states, ordered transitions, playback, and actor-isolation checks passed")
