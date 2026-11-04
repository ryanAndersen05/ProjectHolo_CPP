# Kiara and Ina transition migration

The character scripts remain ordinary, editable Lua state definitions, following
Gura's format. Transitions use ordered arrays and the shared `ipairs` helper;
`any_state` handles global hit/burst routing. No generated runtime state factory
or source-JSON interpreter is required.

Kiara's JSON supplies 56 animation states and 9 routing states; Ina's supplies
53 animation states and 9 routing states. Their Unity state assets and animation
clips supply clip boundaries, sprite events, and grab-animation alternatives.
Multiple clips are expressed as named startup, loop, and recovery states.
Frame-gated transitions use the existing `minFrame` field. Clip-specific cancels
appear only in the applicable phase. Kiara's light self-cancel uses a separate
restart entry because native `SetCurrentState` ignores the active state name.

## Preserving the existing scripts

- Existing populated sprite keyframes, frame durations, movement/jump calls,
  and entry/exit callbacks are retained. Existing state names are reused.
- Missing transitions are added to existing states, and their ticks evaluate
  the ordered arrays. Existing completion checks and additional conditional
  transitions remain. Imported rules retain their JSON order and precede
  additional authored rules; unconditional routing fallbacks come last.
- Existing routing fallbacks take precedence over a conflicting imported
  fallback. In particular, Ina's crouching attack still defaults to crouching
  light; the old JSON instead specified standing light.
- Kiara's existing heavy startup/release/full-charge callbacks and 30-frame
  startup timing remain. The corresponding legacy clip phases are also exposed
  as editable states; the existing completion callback can bypass the imported
  hold phase. This preserves the current charge flow rather than replacing it
  with the old game's timing.
- Missing durations are filled from the clips. Kiara's blank air-hit sprite
  placeholders are populated without changing their existing event frames.
- The default routers now select air/ground state in their first tick, matching
  Gura. Their former immediate idle return would route aerial recovery to idle.
  Deferring the selection also avoids reading parameters before native animator
  initialization has populated them.
- Existing extra effect states in Ina's script remain, including beam, portal,
  tentacle, lightning, and attack-effect animations.

## Sprites

Three source sheets were missing from the current atlases: Kiara's air heavy,
Kiara's forward air-dash recovery, and Ina's air medium. Their frames are added
using `Tools/AtlasCreator.py` packing functions. Existing atlas entries and their
pixel regions are preserved. The new source sheets live alongside the existing
character sheets.

Ina's air-medium frames use a wide source rectangle with an off-center pivot.
The new sheet pads each frame to a square so the packer splits it correctly;
its atlas entries retain the foot position and horizontal pivot from Unity.
The padding is transparent.

## Remaining gameplay work

The transition JSON does not provide the implementation of attacks, damage,
hitboxes, projectile/effect spawning, meter use, sound events, or Unity animation
curves. Existing Lua gameplay callbacks are retained; new states expose ordinary
callbacks/keyframes where those actions can be added. Movement actions for new
states are not inferred from animation names.

The imported parameters include meter, hit confirmation, hit stun/type, grab
selection, win selection, and Kiara's charge/parry inputs. Those rules need their
gameplay producers. Kiara's `hcf`, `chargeH`, and `chargeV` triggers are declared
but are not added to the directional input recognizer in this change.
Horizontal conditions continue to use the engine's existing `hInput` convention.

## Validation

```text
python -B -m unittest discover -s tests/animation -p "test_*conversion.py" -v
```

The bundled Lua runtime checks all three scripts. Kiara/Ina checks cover state
references, parameter references, every sprite keyframe, playback ticks,
walking startup/recovery, retained movement/jump callbacks, global hit/burst
priority, trigger consumption, dash clip gates, EX/super routing, grab variants,
Kiara's heavy release and win selection, and Ina's light follow-up. These checks
use mock actors and do not replace an in-game playtest.
