# Character physics and pushboxes

`EHBoxCollider` is a concrete axis-aligned actor component. The actor origin is
at the feet. `offset` identifies the box bottom-center relative to that origin;
`size` is width and height. Both size components and the vertical offset must
be nonnegative and all bounds must be finite. Zero-area boxes do not collide.

Example prefab component:

```json
{
  "componentType": "boxcollider",
  "componentName": "boxcollider",
  "data": {
    "size": { "x": 1, "y": 2 },
    "offset": { "x": 0, "y": 0 }
  }
}
```

At actor position `(10, 0)`, size `(2, 4)`, and zero offset, the world `FRect`
is bottom-left `(9, 0)` with size `(2, 4)`. Horizontal scale mirrors the offset;
absolute scale determines size. Vertical offset/height always extend upward,
even with negative Y scale. Actor rotation is ignored.

Ina and Kiara, the existing characters with physics and movement components,
have initial 1-by-2 pushboxes. These dimensions are tuning defaults, not
artwork-derived measurements. Gura currently has no physics/movement setup.

## Simulation order

`EHGameMode::TickGameMode` updates component logic, calls
`EHPhysicsSystem::Step(allActors, deltaTime)`, then runs late ticks. Physics is
no longer an `ITickable`: moving an individual actor with `TickActor()` does
not integrate its physics. Standalone callers can use the shared step with a
list of actors (or the existing physics `Tick()` for movement without contacts).
Do not call both physics `Tick()` and the shared step for the same frame.

The shared step discovers components by type, independent of prefab component
names/order. Each actor should have one physics component and at most one
pushbox. Inactive actors are excluded. Physics actors without a collider still
move normally; colliders without physics do not participate in pushing.

Gravity and actor time scale determine intended displacement. The resolver
checks the swept horizontal movement and vertical overlap interval to catch
fast crossings. `FRect::IsOverlapping()` detects existing penetration, which
is corrected equally along X. No character contact changes Y or vertical
velocity. The existing feet-at-Y-zero floor remains in physics until world
boundaries are implemented.

## Horizontal response

Only movement into contact is combined. Movement apart remains free.
Opposite signed velocities add: `+5` versus `-4` produces shared `+1` movement.
Same-direction movement uses the larger magnitude: `-4` versus `-5` produces
`-5`. A moving character pushes a stationary one at its own speed. Input
velocities are retained; shared movement is applied to positions for the
contact portion of that step. Once vertical overlap ends, intended movement
resumes. No bounce, mass, friction, or vertical support is applied.

This resolver is designed for the current two-character fight. Multiple
collider pairs are processed in spatial order, but simultaneous chains of
three or more contacting bodies would need a separate constraint solver.

## Checks

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_PHYSICS_TESTS=ON
cmake --build cmake-build-debug --target ProjectHoloPhysicsTests
ctest --test-dir cmake-build-debug -R character-physics --output-on-failure
```
