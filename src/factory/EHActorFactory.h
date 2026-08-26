#pragma once
#include "core/EHActor.h"
#include "library/EHLibrary.h"

class EHActorFactory {
    const static FName CharacterActorId;
    const static FName CameraActorId;

public:
    static EHActor* CreateActor(const FName& actorId);
};