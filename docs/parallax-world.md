# Parallax backgrounds

`EHParallaxWorld` owns normal sprite components and groups named components into
background layers. Each layer specifies a nonnegative depth `z` and an optional
additional world-space `offset`. Sprite components retain their original offsets,
pivots, shader, actor scale, and draw order.

The layer's camera movement rate is `1 / (1 + z)`. At Z=0, no adjustment is made:
the sprite moves on screen at the full camera rate. At Z=5, camera motion of six
units moves the background only one unit on screen. This applies to X and Y.

Draw collection adds `cameraViewPosition * z / (1 + z)` to the authored sprite
position before normal camera translation. `cameraViewPosition` includes the
camera component offset. Positions are recomputed each draw, avoiding drift and
late-tick ordering dependencies. The rendering context supplies the camera;
without one, authored positions are used. Sprite references are resolved once
when the actor initializes.

## Prefab format

```json
{
  "actorType": "parallaxWorld",
  "data": {
    "spriteAsset": "background_atlas",
    "backgroundLayers": [
      { "componentName": "distant", "z": 5 },
      { "componentName": "nearby", "z": 0, "offset": { "x": 0, "y": -1 } }
    ]
  },
  "components": [
    {
      "componentType": "sprite",
      "componentName": "distant",
      "data": {
        "defaultSprite": "distant_background",
        "spriteOffset": { "x": 0, "y": 0 },
        "drawOrder": -200
      }
    },
    {
      "componentType": "sprite",
      "componentName": "nearby",
      "data": {
        "defaultSprite": "nearby_background",
        "spriteOffset": { "x": 0, "y": 0 },
        "drawOrder": -100
      }
    }
  ]
}
```

`data.spriteAsset` optionally identifies sprite metadata loaded before component
initialization. Layers must reference unique, existing sprite components.
Malformed layer definitions are rejected. A layer's `offset` is added to its
component's `spriteOffset`; neither is modified during rendering.

The fighting game mode now spawns the actor asset selected by `sceneId`.
Atlantis uses the existing sprite sheet split into skyline, ruins, and floor
regions, with depths 5, 2, and 0. These initial placements/pivots can be tuned in
`assets/level/atlantis.json` and `assets/sprites/backgrounds/atlantisAtlas.json`.
No automatic repeating or world boundaries are introduced. Negative sprite
`drawOrder` values place the backgrounds behind characters at order zero.

## Checks

```text
cmake -S . -B cmake-build-debug -DPROJECT_HOLO_BUILD_PARALLAX_TESTS=ON
cmake --build cmake-build-debug --target ProjectHoloParallaxTests
ctest --test-dir cmake-build-debug -R parallax-world --output-on-failure
```

Checks cover multiple depths, both position axes, camera offsets, unchanged base
transforms, lack of accumulated drift, ordering, prefab validation, and factory
creation without opening a graphics window.
