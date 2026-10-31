#pragma once
#include "library/EHLibrary.h"

enum class EHitboxType {
    Hitbox,
    Hurtbox,
};

NLOHMANN_JSON_SERIALIZE_ENUM_STRICT(EHitboxType, {
    {EHitboxType::Hitbox, "Hitbox"},
    {EHitboxType::Hurtbox, "Hurtbox"}
});

class EHHitbox {
private:
    friend class EHHitboxComponent;

    EHitboxType type = EHitboxType::Hitbox;
    FRect localBounds;
    bool isActive = false;

public:
    bool IsHitboxOverlapping(const EHHitbox* other);
};
