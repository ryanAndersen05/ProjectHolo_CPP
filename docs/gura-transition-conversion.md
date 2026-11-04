# Gura transition migration notes

`assets/animation/gura/gura.lua` is an ordinary editable character script, using
the same state-table layout as Ina and Kiara. The previous game's JSON supplies
the missing animation states, parameters, routing decisions, and transitions.
Associated Unity clips supply sprite timing. The maintained artifact is the Lua
script itself; there is no converter or generated playback framework to edit.

## Editing the character

Each animation state is a visible `states.gura_*` block with:

- `keyFrames`: sprite changes and a place to add gameplay events at exact frames.
- `maxFrames`: the clip's authored duration, converted to 60 Hz ticks.
- `transitions`: ordered entries containing `state`, `conditions`, and optional `minFrame`.
- `onEnter`, `tick`, and `onExit`: ordinary editable functions for behavior.

For example, `gura_walkfstart`, `gura_walkf`, and `gura_walkfend` expose the
startup, loop, and recovery as separate states, following Kiara's existing
pattern. Comments above blocks identify the original Unity state and clip.
No runtime factory creates hidden states or clip indices.

## Current-format differences and limitations

1. **Transition priority.** All three character scripts now use ordered arrays:

   ```lua
   transitions = {
       {
           state = "gura_jumpstart",
           conditions = {
               { parameter = "vInput", conditionType = StateMachineCommon.EConditionType.Greater, value = 0 }
           }
       },
       { state = "gura_idle", minFrame = 12, conditions = {} }
   }
   ```

   `StateMachineCommon.evaluateTransitions()` uses `ipairs`. The first matching
   entry wins; an unconditional fallback belongs last. Adding a transition only
   requires adding its entry at the desired position. Ina and Kiara are migrated
   in their authored order, including their duplicate-target fallback entries.

2. **Repeated destinations.** Arrays allow multiple entries with the same
   `state`, so routing choices retain their separate conditions and priorities.

3. **AnyState.** Each character has an optional `states.any_state` table. C++
   evaluates its `tick` before the current state. If it returns a state name,
   normal exit/entry callbacks run and the old state is not ticked that frame.
   Otherwise playback continues normally. The global table is not itself entered
   as a playback state. Missing tables or missing tick functions are skipped.
   Gura's hit/burst rules live there; Ina and Kiara have empty placeholders.

4. **Exit time and clip index.** The optional `minFrame` entry field makes a
   transition eligible at that frame; ticks pass `frame` to the shared helper.
   Gura's old strict completion test is represented by `maxFrames + 1` values.
   Clip windows remain visible startup/loop/recovery states. Their ticks now
   evaluate the same ordered arrays rather than repeating checks per transition.

5. **Self-cancels.** Native `SetCurrentState()` ignores the currently active
   state. `gura_slightrestart` and `gura_clightrestart` are explicit entry states
   that return to those attacks, allowing their frames to restart.

6. **Clip alternatives.** Grab recovery uses a visible `gura_grabbedend` selector
   and separate Gura/Ina/Kiara recovery states. This expresses the source's
   on-entry `GrabId` choice using ordinary state callbacks.

7. **Initial default routing.** Native initialization calls `onEnter` before
   setting up parameters. `gura_default` routes in its first `tick`, when values
   exist. Other routing states use normal `onEnter` functions.

8. **Gameplay data is separate.** Unity callbacks, transform curves, hitboxes,
   damage, projectile/trident spawning, resource changes, and state-entry side
   effects are not supplied by the transition JSON. They still need to be added
   to the visible callbacks/keyframes. Movement, jump, and dash actions are not
   inferred from clip names. Your prefab/component changes are preserved.

9. **Parameter producers.** Existing input names are reused (`button`, `light`,
   `medium`, `heavy`, `special`, `doubleForward`, `doubleBack`, `qcf`, etc.). Held
   buttons (`lightHeld`, etc.) remain separate booleans, and release signals
   remain separate triggers. The current input component does not emit every
   legacy signal. Meter, hit-confirm, hit-stun, death, grab, and similar values
   need their gameplay producers. Horizontal conditions still use the current
   engine's world-relative `hInput`; facing behavior is unchanged.

The three current grab-miss frames differ from the old artwork; corresponding
current `gura_grabmiss00` through `02` sprites are used. Other body frames were
matched against the current atlas by pixel content. Redundant repeated sprite
keys were omitted without changing the authored duration.

## Validation

```text
python -B -m unittest discover -s tests/animation -p test_gura_conversion.py -v
```

The Lua checks execute the actual scripts through the bundled Lua 5.4 DLL with mock actor
APIs. They validate sprite references, visible state hooks, transition priority,
trigger consumption, startup/loop/recovery timing, dash cancel windows, resource
routing, self-cancels, grab recovery selection, and isolation between actors.
They do not exercise graphics or the unported gameplay actions.

Native optional-global-state checks:

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_ANIMATOR_TESTS=ON
cmake --build cmake-build-debug --target ProjectHoloAnimatorTests
ctest --test-dir cmake-build-debug -R animator-any-state --output-on-failure
```

These exercise the real animator's global-first ordering, transition callbacks,
frame reset, and normal playback with an absent or empty `any_state`.
