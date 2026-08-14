#include "EHActorComponentFactory.h"

#include "character/EHCharacterMovementComponent.h"
#include "library/EHJsonManager.h"
#include "physics/EHPhyicsComponent.h"
#include "sprite/EHSpriteComponent.h"

const FName EHActorComponentFactory::SpriteComponentId = FName("sprite");
const FName EHActorComponentFactory::PhysicsComponentId = FName("physics");
const FName EHActorComponentFactory::CharacterMovementComponentId = FName("characterMovement");


EHActorComponent* EHActorComponentFactory::CreateActorComponent(const json& componentJson) {
    FName actorId = componentJson.at("componentId").get<FName>();

    if (actorId == SpriteComponentId) return new EHSpriteComponent(componentJson.at("data").get<EHSpriteComponent>());
    if (actorId == PhysicsComponentId) return new EHPhysicsComponent();
    if (actorId == CharacterMovementComponentId) return new EHCharacterMovementComponent();

    return nullptr;
}
