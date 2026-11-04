#include "EHActorFactory.h"
#include "camera/EHFollowCamera.h"
#include "character/EHCharacter.h"
#include "controller/EHPlayerController.h"
#include "world/EHParallaxStage.h"
#include "world/EHWorld.h"

const FName EHActorFactory::CharacterActorId = FName("character");
const FName EHActorFactory::PlayerControllerActorId = FName("playercontroller");
const FName EHActorFactory::CameraActorId = FName("followCamera");

const FName EHActorFactory::WorldActorId = FName("world");
const FName EHActorFactory::ParallaxStageActorId = FName("parallaxStage");

EHActor* EHActorFactory::CreateActor(const FName& actorId, const json& data) {
    if (actorId == CharacterActorId) return new EHCharacter();
    if (actorId == PlayerControllerActorId) return new EHPlayerController();
    if (actorId == CameraActorId) return new EHCameraFollow();
    if (actorId == WorldActorId) return new EHWorld(data.get<EHWorld>());
    if (actorId == ParallaxStageActorId) return new EHParallaxStage(data.get<EHParallaxStage>());
    return nullptr;
}