#pragma once
#include "sprite/EHSpriteManager.h"
#include <vector>

class EHGameMode;
class EHCamera;

struct FRenderContext {
    const EHGameMode* gameMode = nullptr;
    const EHCamera* camera = nullptr;
};

struct FRectangleDrawCommand {
    FRect bounds; // World-space bounds, with a bottom-left origin.
    sf::Color fillColor;
    sf::Color outlineColor;
};

// Debug rectangles always render after sprites, in submission order.
struct FRenderQueue {
    std::vector<FSpriteDisplayData> sprites;
    std::vector<FRectangleDrawCommand> debugRectangles;
};
