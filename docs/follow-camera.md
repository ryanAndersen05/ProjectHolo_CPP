# Follow camera

`EHCameraFollow` follows its registered active targets after physics each frame.
The actor implements `ILateTickable`; actor-level late ticks are now included in
`EHActor::LateTickActor` and `GetIsLateTickable`, alongside component late ticks.
The fighting game mode registers spawned player characters as camera targets.

The camera actor position is computed as:

```text
x = sum(active target x positions) / active target count
y = max(0, highest active target y - heightThreshold)
```

The default threshold is 5 world units. A highest target at Y=5 keeps the camera
at Y=0, Y=6 raises it to Y=1, and falling below the threshold returns it to Y=0.
`SetHeightThreshold()` changes this at runtime (negative values clamp to zero).
Height is measured at each target's actor origin, which is at character feet.

`AddTargetActor()` ignores nulls, the camera itself, and duplicate targets.
`RemoveTargetActor()` removes a target. With no active targets the camera keeps
its last position. Targets remain non-owning pointers; remove them before
explicitly destroying their actors. Characters otherwise remain alive between
rounds under the game's existing lifecycle.

The camera component retains its configured viewport size and offset. The
production camera prefab offset is now zero so the target average is centered;
it previously added a two-unit horizontal shift. Camera Y projection now moves
the scene down when the camera moves up, consistent with upward-positive world Y.
Sprites and debug rectangles use the same camera translation.

Following is immediate, with no smoothing, automatic zoom, or stage clamping.
The fixed viewport can only contain targets within its configured size; arbitrary
separation would require zoom or world movement limits in a future change.

## Checks

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_CAMERA_TESTS=ON
cmake --build cmake-build-debug --target ProjectHoloCameraTests
ctest --test-dir cmake-build-debug -R follow-camera --output-on-failure
```
