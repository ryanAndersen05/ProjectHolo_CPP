#pragma once
#include "sprite/EHSpriteManager.h"

class IDisplayable {
public:
    [[nodiscard]] virtual FSpriteDisplayData GetSpriteDrawData() const = 0;
};
