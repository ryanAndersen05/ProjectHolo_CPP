# World bounds and character spawns

`EHWorld` is a prefab-backed actor defining shared gameplay rules and spawn points.
`EHParallaxStage` is a separate actor defining only scene backgrounds. Both derive
directly from `EHActor`; a background stage never replaces the active gameplay
world. The fighting game mode loads `default_world` independently, then loads the
background asset selected by `sceneId`.

```json
{
  "actorType": "world",
  "data": {
    "worldSize": 15,
    "spawnPoints": [
      { "x": -3, "y": 0 },
      { "x": 3, "y": 0 }
    ]
  },
  "components": []
}
```

A reusable plain-world prefab is registered as `default_world` at
`assets/prefabs/world/world.json`. Edit this prefab to change the rules shared by
Atlantis and other background scenes. Atlantis keeps its authored parallax layers
and has no `worldSize` or `spawnPoints` fields.

## Coordinates

The world is centered at X=0. `worldSize` is the full horizontal span, so 15
allows character actor positions from -7.5 through +7.5, inclusive. The actor
origin is at the feet; bounds constrain that origin rather than shrinking the
range by the sprite or collider width. World actor position/scale does not
translate or resize this gameplay range.

Spawn points are absolute world-space feet positions, in player-setting order.
`EHGameModeFighting` uses these instead of hardcoded +/-3 positions and requires
one spawn point per configured player. JSON rejects nonpositive/nonfinite sizes,
nonfinite points, X values outside the world, and Y values below the current floor.
`GetSpawnPoint(index)` returns an optional for callers that need a bounds-checked
lookup; `GetSpawnPoints()` exposes the complete read-only list.

## Physics integration

`EHGameModeFighting` creates and retains its gameplay world explicitly through
`InitializeWorld()` and exposes it through `GetWorld()`. Training modes inherit
this behavior. Its `Simulate()` override passes the protected read-only actor
list and world to `EHPhysicsSystem::Step`. Creating another world or background
actor through the generic actor factory does not replace that selected world.
Destroying it clears the fighting mode's reference, including when destruction
is requested through an `EHGameMode` reference. Actor lifetime remains owned by
the base game mode's collection.

The generic `EHGameMode` owns no world reference and has no world accessor.
Its empty `Simulate()` hook keeps menus and other generic modes free of automatic
physics, while preserving actor ticks and late ticks.

After normal movement and character contacts, active `EHCharacter` positions
are clamped to the horizontal range. Vertical movement is unchanged. A second
horizontal contact correction transfers separation away from a character pinned
to an edge, preventing overlap from repeated pushing into the wall. Existing
horizontal velocity remains movement intent, so input can continue pushing and
characters can immediately move back toward the stage interior.

Non-character physics actors and cameras are not constrained. A null world keeps
the earlier unrestricted physics behavior. Character contacts retain the current
two-fighter scope; impossible configurations where bodies cannot fit within the
available range prioritize the position limits.

World prefabs require both `worldSize` and `spawnPoints`. Background prefabs use
`actorType: "parallaxStage"` and contain only their visual layer configuration.

## Checks

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_WORLD_TESTS=ON
cmake --build cmake-build-debug --target ProjectHoloWorldTests
ctest --test-dir cmake-build-debug -R world-bounds --output-on-failure
```

Checks cover parsing, spawn lookup, validation, separate world/stage factory types,
large movement at both edges, vertical movement, movement away from an edge,
corner pushing in both actor orders, existing interior push behavior, unbounded
non-character actors, generic modes without physics, inherited fighting/training simulation, world
lifetime handling, camera update order, and production stage data.
