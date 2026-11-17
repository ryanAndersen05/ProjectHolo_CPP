# Gameplay abilities

`EHAbilitySystemComponent` owns each actor's attributes, granted abilities, active
effects, and tag counts. C++ enforces activation gates, modifier calculation,
duration expiry, and cleanup. Lua composes those operations into individual
ability behaviors. Animation states still own sprite/hitbox frame timing.

## Configuring an actor

The component factory type and default component name are `abilitysystem`.
The character prefabs grant the two proof-of-concept abilities below and define
health/maxHealth as 1000 and meter as 0. These are editable starting values.
Neither example is automatically bound to input or animation states.

```json
{
  "componentType": "abilitysystem",
  "componentName": "abilitysystem",
  "data": {
    "attributes": {
      "maxHealth": { "base": 1000, "min": 0 },
      "health": { "base": 1000, "min": 0, "maxAttribute": "maxHealth" },
      "meter": { "base": 0, "min": 0 }
    },
    "abilities": ["ability_basic_damage", "ability_guard"]
  }
}
```

Attribute/ability/tag IDs use `FName`; native code should cache repeated names as
static constants. `GetAttribute` returns an optional in C++ and nil in Lua for a
missing attribute. Native `OnAttributeChanged(name, old, new)` reports calculated
value changes. `SetBaseAttribute` clamps to configured bounds. `maxAttribute`
can reference another attribute; missing references and cycles are rejected.
Reducing an upper bound also clamps the bounded attribute's base, so excess
health is not stored as a reserve. A bound cannot force a value below its minimum.

Components initialize in prefab order. Place an ability system after components
that its `onInitialize`/activate-on-grant callbacks need. The example callbacks
have no such dependencies, so their components can initialize first.

## Defining an ability

Register the JSON definition and Lua script in `assetPathDataTable.json`.
`assets/abilities/guard.json` demonstrates a Lua ability with an owned tag:

```json
{
  "scriptAsset": "ability_timed_script",
  "blockedTags": ["stunned"],
  "ownedTags": [{ "tag": "invulnerable" }],
  "config": { "durationFrames": 12 }
}
```

Optional definition fields:

| Field | Meaning |
|---|---|
| `requiredTags` | All must be present to activate; losing one ends the ability. |
| `blockedTags` | Any present tag blocks activation and cancels an active ability. |
| `activationTags` | A nonempty list automatically activates when all are present; losing one ends it. |
| `ownedTags` | Counted tag contributions added on begin and removed on end. |
| `effectsOnBegin` | Effects applied to the owner; retained applications are removed on end. Instant changes remain. |
| `activateOnGrant` | Attempt activation after initialization. |
| `removeOnEnd` | Remove the granted instance after ending. |
| `config` | Data copied into this instance's Lua `self.config`. |

One ability ID can be granted once per actor. Different IDs can reference the
same script with different configuration. Ending preserves the grant, so it can
be activated again. Removing calls end/cleanup and releases the Lua instance.

The Lua file returns a table with any of these callbacks:

```lua
local ability = {}

function ability.onBegin(self, context)
    self.frames = 0
end

function ability.onTick(self, context, deltaTime)
    self.frames = self.frames + 1
    if self.frames >= self.config.durationFrames then
        context:End()
    end
end

return ability
```

Callbacks are `onInitialize(self, context)`,
`canActivate(self, context, target)` (return a boolean),
`onBegin(self, context)`, `onTick(self, context, deltaTime)`,
`onEnd(self, context)`, and `onUninitialize(self, context)`.
Only active abilities tick. Each grant gets a separate `self` and config table;
store mutable gameplay data there, rather than in module-level variables.
Lua callback failures are reported and active abilities are ended for cleanup.

The native context exposes `Actor()`, `Target()`, `System()`, `Id()`,
`IsActive()`, and `End()`. `Target()` is the actor supplied on activation and is
available through the end callback. Context pointers belong to the grant and
must not be retained after removal.

## Calling from animation/combat code

```lua
-- A state may begin guard on entry and end it when interrupted or exited.
actor:Abilities():ActivateAbility("ability_guard")
actor:Abilities():EndAbility("ability_guard")

-- Call after hit confirmation, passing the defending actor.
attacker:Abilities():ActivateAbility("ability_basic_damage", defender)
```

The damage example rejects missing targets and invulnerable defenders, applies
`effect_basic_damage` to the defender, and ends itself immediately. The amount is
25 in the effect JSON. An activation returning true means it began; a one-shot
ability may already have ended when the call returns. The guard example grants
invulnerability for 12 active simulation ticks. Calls using an optional component
name are supported: `actor:Abilities("custom_component_name")`.

The Lua component API also exposes `GrantAbility`, `RemoveAbility`,
`IsAbilityActive`, `GetAttribute`, `SetBaseAttribute`, `ApplyEffect`,
`RemoveEffect`, `HasEffect`, `AddTag`, `RemoveTag`, `HasTag`, and `GetTagCount`.

## Effects and tags

Effects are JSON assets containing `type`, optional `durationFrames`,
`modifiers`, and `tags`. Each modifier specifies `attribute`, `type`, and `value`.
Modifier types are Set, Add, Subtract, Multiply, and Divide, evaluated in that
order. Equal operations retain application order; later Set modifiers win.
Each effect is validated completely before changing the actor.
Definitions are loaded on first use and cached by the component, so repeated
applications do not repeatedly read JSON from disk.

- Instant effects change base values and leave no active effect behind. They
  do not bake temporary modifiers into the base. They cannot grant lasting tags.
- Duration effects retain modifiers/tags until their positive `durationFrames`
  count expires. Effects present at the start of a positive-time component tick
  lose one frame; effects applied by that component's tick begin counting next tick.
- Infinite effects retain modifiers/tags until manually removed.

`ApplyEffect` returns an `FEffectHandle` identifying that application. An invalid
handle means rejection. Instant successes return a valid receipt, but `HasEffect`
is false because nothing remains to remove. Retained handles can be passed to
`RemoveEffect`; removing an expired or already removed handle returns false.
An ability cleans up its `effectsOnBegin` applications. If Lua applies additional
effects, it should retain their handles in `self` and remove them in `onEnd` when
their lifetime belongs to that ability.

Tags match exact names and count contributors. Two guard effects can both grant
invulnerability; removing one leaves the other contribution active. Native
`OnTagChanged(name, count)` reports count changes. Manual AddTag/RemoveTag calls
must be balanced by their caller. A tag does not supply behavior automatically;
the damage example explicitly checks invulnerability.

Native `OnAbilityActiveChanged(id, active)` reports activation/end transitions.
Attribute/tag/activation notifications are delivered after the current operation
has finished, so callbacks see coherent state. Notifications and removals can
cause further operations without invalidating a ticking ability. Event listener
lists are snapshotted during notification; listener edits affect the next invoke.

## Lifetime and current scope

Actor cleanup ends/removes abilities while sibling components remain valid.
Game-mode cleanup uninitializes every actor before deleting any of them, and
the game instance keeps Lua/managers alive until that cleanup completes.

Hit confirmation, hit stun/knockback, meter costs, cooldown policy, cues/audio,
round resets, and rollback snapshots remain separate integration work. Existing
animation states and hitbox behavior have not been assigned new combat rules.
The initial effect source is tracked, but this version does not implement a
full damage-event payload or source-based scaling. Timers are simulation-frame
counts; nonzero actor time scaling does not change the number of ticks consumed.

## Verification

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_ABILITY_TESTS=ON
cmake --build cmake-build-debug --target ProjectHoloAbilityTests ProjectHolo_CPP
ctest --test-dir cmake-build-debug -R gameplay-abilities --output-on-failure
```

Native checks exercise the actual Lua bindings and editable example assets,
actor isolation, damage/guard, attribute bounds, instant and temporary modifiers,
effect/tag ownership, expiry, activation gates, self-removal, callback reentry,
invalid script loading, and teardown. They do not replace an in-game playtest.
