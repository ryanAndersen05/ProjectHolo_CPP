#include "EHActorFactory.h"
#include "character/EHGura.h"

const FName EHActorFactory::GuraActorId = FName("gura");
const FName EHActorFactory::CharacterActorId = FName("character");

EHActor* EHActorFactory::CreateActor(const FName& actorId) {
    if (actorId == CharacterActorId) return new EHCharacter();
    if (actorId == GuraActorId) return new EHGura();
    return nullptr;
}