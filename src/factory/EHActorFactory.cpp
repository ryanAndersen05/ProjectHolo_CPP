#include "EHActorFactory.h"
#include "camera/EHFollowCamera.h"
#include "character/EHCharacter.h"
#include "controller/EHPlayerController.h"
#include "world/EHParallaxWorld.h"

const FName EHActorFactory::CharacterActorId = FName("character");
const FName EHActorFactory::PlayerControllerActorId = FName("playercontroller");
const FName EHActorFactory::CameraActorId = FName("followCamera");

const FName EHActorFactory::ParallaxWorldActorId = FName("parallaxWorld");

EHActor* EHActorFactory::CreateActor(const FName& actorId, const json& data) {
    if (actorId == CharacterActorId) return new EHCharacter();
    if (actorId == PlayerControllerActorId) return new EHPlayerController();
    if (actorId == CameraActorId) return new EHCameraFollow();
    if (actorId == ParallaxWorldActorId) return new EHParallaxWorld(data.get<EHParallaxWorld>());
    return nullptr;
}