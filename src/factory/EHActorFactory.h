#pragma once
#include "core/EHActor.h"
#include "library/EHLibrary.h"

class EHActorFactory {
    const static FName CharacterActorId;
    const static FName PlayerControllerActorId;
    const static FName CameraActorId;
    const static FName ParallaxStageActorId;
    const static FName WorldActorId;

public:
    static EHActor* CreateActor(const FName& actorId, const json& data = json::object());
};