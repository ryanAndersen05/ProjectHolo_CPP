# Project Holo Animation Editor

From the repository root, install Pillow and launch the editor with Python 3.10 or later and Tkinter. It opens Kiara by default.

```powershell
python -m pip install "Pillow>=9.1"
python Tools/AnimationEditor.py
```

Use **Open Lua…** to switch characters. The editor resolves the atlas and its texture through the game's asset table and looks for the matching character prefab. You can also provide asset paths explicitly.

```powershell
python Tools/AnimationEditor.py assets/animation/kiara/kiara.lua --atlas assets/sprites/characters/kiara/kiaraAtlas.json --texture assets/sprites/characters/kiara/kiaraAtlas.png --prefab assets/prefabs/characters/kiara/kiara.json
```

1. Pick a state and click an existing keyframe or enter a frame index and click **Go**. A frame between keys previews the last literal sprite assignment. Choose or type an atlas sprite ID to set the sprite at the selected frame.
2. Select a box from the list or choose **New box**, enter a name, and choose Hitbox or Hurtbox. Drag on the sprite to draw or redraw its bounds, or enter exact game units and click **Apply box values**. Apply changes to the active checkbox with the same button. Red outlines are hitboxes, blue outlines are hurtboxes, and dashed outlines are inactive.
3. Click **Copy keyframe Lua** to paste into the selected state's `keyFrames` table. Replace the existing entry including its separator, or insert the new entry. For a state without a table, paste the whole copied `keyFrames` field into the state. **Write keyframe to Lua…** applies the same change in place after confirmation. Finish each draft before navigating away.

Click **Play** to preview the selected state at 60 frames per second with its sprite and box overlays. **Pause** lets you edit the current frame. Playback loops by default. Clear **Loop** to stop on the final frame. The preview runs through the state's `maxFrames` or its last authored keyframe, whichever extends farther.

The white cross is the atlas pivot. Each grid square is 32 texture pixels, or one game unit. Box X and Y locate the lower-left corner relative to the pivot, with Y increasing upward. Mouse drags snap to whole texture pixels.

Gameplay resolves box names against the actor's `hitbox` component. Kiara currently needs this component. After drawing a box, use **Copy prefab box component** and add the JSON object to the character prefab's `components` array. If the component already exists, merge the new named entries into its `hitboxes` array. Newly exported definitions start inactive. Add a later key with the box inactive, or deactivate it in `onExit`, when an active box should stop applying. Runtime bounds and activation carry across frames and state transitions until changed.

The editor reads literal state tables, frame callbacks, sprite IDs, and numeric box calls. The preview starts from prefab defaults and applies the selected state's `onEnter` and earlier keys in frame order. It does not run Lua, evaluate conditions, simulate state transitions, or preview palette shaders. The game still determines whether a key is reached through the state's tick logic and `maxFrames`. Box exports write `SetBounds` and `SetActive` calls for the drafted boxes. The component guard allows the script to load before the prefab is configured.
