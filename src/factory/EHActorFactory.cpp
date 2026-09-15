#include "EHActorFactory.h"
#include "camera/EHFollowCamera.h"
#include "character/EHCharacter.h"
#include "controller/EHPlayerController.h"

const FName EHActorFactory::CharacterActorId = FName("character");
const FName EHActorFactory::PlayerControllerActorId = FName("playercontroller");
const FName EHActorFactory::CameraActorId = FName("followCamera");

EHActor* EHActorFactory::CreateActor(const FName& actorId) {
    if (actorId == CharacterActorId) return new EHCharacter();
    if (actorId == PlayerControllerActorId) return new EHPlayerController();
    if (actorId == CameraActorId) return new EHCameraFollow();
    return nullptr;
}