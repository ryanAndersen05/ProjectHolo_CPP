#include "EHActorComponentFactory.h"

#include "physics/EHPhyicsComponent.h"
#include "sprite/EHSpriteComponent.h"

const FName EHActorComponentFactory::SpriteComponentId = FName("sprite");
const FName EHActorComponentFactory::PhysicsComponentId = FName("physics");
const FName EHActorComponentFactory::CharacterMovementComponentId = FName("characterMovement");


EHActorComponent* EHActorComponentFactory::CreateActorComponent(const FName &actorId) {
    if (actorId == SpriteComponentId) return new EHSpriteComponent();
    else if (actorId == EHActorComponentFactory::PhysicsComponentId) return new EHPhysicsComponent();

    return nullptr;
}
