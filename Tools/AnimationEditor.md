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
2. Select a box from the list or choose **New box** and enter a name. Drag on the sprite to draw or redraw its bounds, or enter exact game units and click **Apply box values**. Apply changes to the active checkbox with the same button. Bounds edits keep the current activation unless the checkbox changes it. The prefab supplies each box type. Red outlines are hitboxes, blue outlines are hurtboxes, gray outlines have no matching prefab definition, and dashed outlines are inactive.
3. Click **Copy keyframe Lua** to paste into the selected state's `keyFrames` table. Replace the existing entry including its separator, or insert the new entry. For a state without a table, paste the whole copied `keyFrames` field into the state. **Write keyframe to Lua…** applies the same change in place after confirmation. Finish each draft before navigating away.

Click **Play** to preview the selected state at 60 frames per second with its sprite and box overlays. **Pause** lets you edit the current frame. Playback loops by default. Clear **Loop** to stop on the final frame. The preview runs through the state's `maxFrames` or its last authored keyframe, whichever extends farther.

To retime an existing keyframe, select it and click **Move keyframe…** below the keyframe list. Enter a free frame number to update the open Lua file and jump to that frame. The move changes only the numeric key. Check `maxFrames` and the state's tick logic when moving a key later in the animation.

Select a box and click **Clear bounds**, **Clear activation**, or **Clear both** to delete the corresponding editor-authored Lua calls from the selected keyframe. The preview shows the values inherited from the prefab or earlier Lua. Copy or write the keyframe to apply the change. Clear controls apply to editor-authored commands, including unsaved drafts. Handwritten Lua calls can be edited in the script.

The white cross is the atlas pivot. Each grid square is 32 texture pixels, or one game unit. Box X and Y locate the lower-left corner relative to the pivot, with Y increasing upward. Mouse drags snap to whole texture pixels.

Gameplay resolves box names against the actor's `hitbox` component. Define each box name, type, and initial bounds in that component's `hitboxes` array in the character prefab JSON. Reopen the Lua script in the editor after changing the prefab.

When exporting a keyframe, the editor syncs `onExit` cleanup for boxes explicitly activated in that state's literal keyframes, `onEnter`, or `tick`. Use a later key with the box inactive if it should stop applying before the state exits. If the cleanup changes, **Copy keyframe Lua** copies the whole state assignment so the keyframe and `onExit` can be pasted together. Dynamic activation in custom Lua needs its own cleanup.

The editor reads literal state tables, frame callbacks, sprite IDs, and numeric box calls. The preview starts from prefab defaults and applies the selected state's `onEnter` and earlier keys in frame order. It does not run Lua, evaluate conditions, simulate state transitions, or preview palette shaders. The game still determines whether a key is reached through the state's tick logic and `maxFrames`. Box exports write `SetBounds` and `SetActive` calls for the drafted boxes. The component guard allows the script to load before the prefab is configured.
