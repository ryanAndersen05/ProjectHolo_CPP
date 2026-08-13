#include "EHActorFactory.h"
#include "character/EHGura.h"

const FName EHActorFactory::GuraActor = FName("gura");

EHActor* EHActorFactory::CreateActor(const FName& actorId) {
    if (actorId == GuraActor) return new EHGura();
    return nullptr;
}