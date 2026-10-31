# Hitboxes controlled through Lua

Attach a `hitbox` component to an actor prefab. Place it **before the animator**
when animation `onEnter` callbacks use it: components initialize in prefab order.

```json
{
  "componentType": "hitbox",
  "componentName": "hitbox",
  "data": {
    "hitboxes": [
      {
        "name": "attack",
        "type": "Hitbox",
        "position": { "x": 0.5, "y": 0.25 },
        "size": { "x": 1, "y": 0.75 }
      },
      {
        "name": "body",
        "type": "Hurtbox",
        "position": { "x": -0.5, "y": 0 },
        "size": { "x": 1, "y": 2 },
        "active": true
      }
    ]
  }
}
```

Names must be nonempty and unique within the component. Types are `Hitbox` and
`Hurtbox` (case-sensitive). `active` defaults to `false`; the other box fields are
required. An empty `hitboxes` array is valid. Prefab loading rejects invalid
definitions without partially replacing an existing component's boxes.

Positions are always **actor-local bottom-left corners**, in game units with Y
pointing up. Sizes must be nonnegative; zero-sized boxes are allowed. Coordinates,
sizes, and their resulting maximum bounds must be finite.

World bounds follow actor position and scale. Negative scale mirrors both corners
and normalizes the resulting rectangle; its position remains the bottom-left
corner. Actor rotation is ignored. Local bounds are preserved when the actor
moves or turns, and inactive boxes still have queryable bounds.

## Lua API

`actor:Hitbox()` returns the component named `hitbox`.
`actor:Hitbox("customName")` selects another component name. Missing components
and components of the wrong type return `nil`. Box names cross the binding as
strings and become `FName` keys for C++ lookup. Scripts cannot access mutable
`EHHitbox` objects or the component's collection.

| Method | Result |
| --- | --- |
| `SetActive(name, active)` | Whether the update succeeded |
| `SetPosition(name, x, y)` | Whether the update succeeded |
| `SetSize(name, width, height)` | Whether the update succeeded |
| `SetBounds(name, x, y, width, height)` | Whether the update succeeded |
| `ResetOverlappingComponents()` | Clears this component's hit history |

Lua animations set actor state through these commands. Read queries remain
available in C++. Setters return `false` for missing boxes or invalid geometry
and leave existing state unchanged. They do not create boxes or change their
type. Active lists update automatically when activation changes; repeating the
same activation state does not add duplicate entries.

Call the setters from existing Lua animation callbacks, preserving the sprite
and movement work those callbacks already perform:

```lua
-- During an attack's active frame:
local boxes = actor:Hitbox()
boxes:ResetOverlappingComponents() -- Start a new hit window when the move requires it.
boxes:SetBounds("attack", 0.5, 0.25, 1, 0.75)
boxes:SetActive("attack", true)

-- A later frame can reposition or resize the active box:
boxes:SetPosition("attack", 0.75, 0.25)
boxes:SetSize("attack", 1.25, 0.75)

-- In the attack state's onExit callback, including interruptions:
actor:Hitbox():SetActive("attack", false)
```

Lua owns activation timing and cleanup. The engine preserves box state across
animation transitions until Lua changes it. Reset clears hit history while
preserving activation and geometry. Neither toggling boxes nor transitioning
animations resets history automatically.

## Component overlap checks in C++

`DoesHitboxComponentOverlap(otherComponent, outHitPosition)` compares this
component's active `Hitbox` boxes against the other component's active `Hurtbox`
boxes. The check is directional. Checking the reverse attack direction requires
a separate call on the other component. Supported directed type pairs are
defined together internally for future extension.

```cpp
FVector hitPosition;
if (attacker->DoesHitboxComponentOverlap(defender, hitPosition)) {
    // hitPosition is the world-space center of the intersecting area.
}
```

The first overlapping pair wins, following active-list order: prefab order for
initially active boxes, then activation order for newly enabled boxes. World
bounds reflect current actor transforms and box geometry. Touching edges and
zero-area boxes do not count as overlaps.

Success records the other component, so further checks against it return
`false` until `ResetOverlappingComponents()` is called. Other targets remain
eligible. Definition reloads also preserve history; reset explicitly when
starting a new hit window. Overlap checks are non-const because they record hits.

Null, self, unattached, previously recorded, and non-overlapping components
return `false` without changing the output position or history. Failed prefab
loads preserve both definitions and active lists; successful loads rebuild
the active lists from the replacement definitions.

The caller selects which components to check. Global collision scheduling,
damage, and debug drawing are not part of this component API.

## Smoke checks

With CMake and the configured compiler available, run from the repository root:

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_HITBOX_TESTS=ON
cmake --build cmake-build-debug --target ProjectHolo_CPP ProjectHoloHitboxTests
ctest --test-dir cmake-build-debug -R hitbox-control --output-on-failure
```

Tests are optional and disabled by default. The checks use separate fixture
assets through the real actor/component factories, scripting system, and
animator, without opening a game window or changing production character moves.
