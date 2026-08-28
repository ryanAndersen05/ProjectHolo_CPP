#pragma once
#include "library/EHLibrary.h"
#include "core/EHActorComponent.h"
#include "nlohmann/json.hpp"
using json = nlohmann::json;

class EHActorComponentFactory {

public:
    const static FName SpriteComponentId;
    const static FName PhysicsComponentId;
    const static FName CharacterMovementComponentId;
    const static FName AnimatorComponentId;
    const static FName CameraComponentId;
    const static FName ColorPaletteComponentId;

    static EHActorComponent* CreateActorComponent(const FName& componentType, const json& componentData);
};