#pragma once
#include "core/EHActor.h"
#include "library/EHLibrary.h"

class EHActorFactory {
    const static FName GuraActor;

public:
    static EHActor* CreateActor(const FName& actorId);
};