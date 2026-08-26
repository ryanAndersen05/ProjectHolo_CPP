#include "EHActorFactory.h"

#include "camera/EHFollowCamera.h"
#include "character/EHGura.h"

const FName EHActorFactory::CharacterActorId = FName("character");
const FName EHActorFactory::CameraActorId = FName("followCamera");

EHActor* EHActorFactory::CreateActor(const FName& actorId) {
    if (actorId == CharacterActorId) return new EHCharacter();
    if (actorId == CameraActorId) return new EHCameraFollow();
    return nullptr;
}