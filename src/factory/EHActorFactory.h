#pragma once
#include "core/EHActor.h"
#include "library/EHLibrary.h"

class EHActorFactory {
    const static FName GuraActorId;
    const static FName CharacterActorId;

public:
    static EHActor* CreateActor(const FName& actorId);
};