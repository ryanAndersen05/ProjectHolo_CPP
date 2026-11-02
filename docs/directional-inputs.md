# Directional input recognition

`EHInputComponent` recognizes motions from the controller's existing frame
history. `EHDirectionalInputTree` stores patterns in reverse order and selects
the deepest completed match ending on the current direction change. Its default
tree is shared and immutable after construction.

Directions use `EDirectionalInput`: DownBack, Down, DownForward, Back, Neutral,
Forward, UpBack, Up, and UpForward. The entire search window is interpreted using
the actor's current facing (`scale.x < 0` means facing left), matching the C#
version. Animator `hInput` and `vInput` remain world-relative.

## Events and triggers

The C++ delegate `OnDirectionalInputEvent` receives `(EDirectionalMotion, frame)`.
Each completed motion also buffers its animator trigger:

| Motion | Animator trigger |
| --- | --- |
| DoubleForward | `doubleForward` |
| DoubleBack | `doubleBack` |
| DoubleDown | `doubleDown` |
| QuarterCircleForward | `qcf` |
| QuarterCircleBack | `qcb` |
| DoubleQuarterCircleForward | `doubleQcf` |

The production character Lua parameter tables declare these triggers. No moves
or dash actions are assigned automatically: states can combine motion triggers
with attack triggers, or C++ listeners can respond to the delegate.

## Timing and matching

The window contains the current frame and the preceding 19 frames. Consecutive
identical normalized directions collapse into a single step. Both press and
release events participate, but a frame is processed only once even when it
emits both callbacks. Attack-only events and held directions do not repeat a
completed motion. Opposite directional buttons cancel through the existing
controller axis calculation before history is collapsed.

All 14 C# patterns are retained: strict and lenient quarter-circles, the three
forward/back double-tap variants, double down, and the three double-quarter-circle
variants. Unrelated intervening directions break a path rather than being
skipped. Longer completed paths take priority on the completing frame. The QCF
trigger emitted by the first quarter-circle can still be buffered when DoubleQCF
completes; action priority remains the state machine's responsibility.

Triggers expire after eight input-component ticks. Repeating an input refreshes
its full buffer instead of shortening it. Unbinding a controller clears input
buffers and recognition bookkeeping. Rebinding does not scan old motion sequences
from before the first input update on the new binding, apart from its immediately
preceding direction sample.

Controllers must tick before actor logic so animation sees newly recognized
inputs on the same simulation step. Input aging retains its existing actor
component phase; production character prefabs place the animator before input.

## Checks

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_INPUT_TESTS=ON
cmake --build cmake-build-debug --target ProjectHoloInputTests
ctest --test-dir cmake-build-debug -R directional-input --output-on-failure
```

Tests exercise all variants while facing both ways, held directions, direction
interruption, the window boundary, simultaneous press/release, current-facing
history, trigger expiry/refresh, and controller rebinding with isolated Lua assets.
