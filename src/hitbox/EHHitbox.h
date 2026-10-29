#pragma once
#include "library/EHLibrary.h"

enum class EHHitboxType {
    Hitbox,
    Hurtbox,
};

NLOHMANN_JSON_SERIALIZE_ENUM_STRICT(EHHitboxType, {
    {EHHitboxType::Hitbox, "Hitbox"},
    {EHHitboxType::Hurtbox, "Hurtbox"}
});

class EHHitbox {
private:
    friend class EHHitboxComponent;

    EHHitboxType type = EHHitboxType::Hitbox;
    FRect localBounds;
    bool isActive = false;
};
