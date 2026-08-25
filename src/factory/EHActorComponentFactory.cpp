#include "EHActorComponentFactory.h"
#include "character/EHCharacterMovementComponent.h"
#include "library/EHJsonManager.h"
#include "physics/EHPhyicsComponent.h"
#include "sprite/EHSpriteComponent.h"


const FName EHActorComponentFactory::SpriteComponentId = FName("sprite");
const FName EHActorComponentFactory::PhysicsComponentId = FName("physics");
const FName EHActorComponentFactory::CharacterMovementComponentId = FName("characterMovement");
const FName EHActorComponentFactory::AnimatorComponentId = FName("animator");


EHActorComponent* EHActorComponentFactory::CreateActorComponent(const FName& componentType, const json& componentData) {

    if (componentType == SpriteComponentId) return new EHSpriteComponent(componentData.get<EHSpriteComponent>());
    if (componentType == PhysicsComponentId) return new EHPhysicsComponent(componentData.get<EHPhysicsComponent>());
    if (componentType == CharacterMovementComponentId) return new EHCharacterMovementComponent(componentData.get<EHCharacterMovementComponent>());
    if (componentType == AnimatorComponentId) return new EHAnimatorComponent(componentData.get<EHAnimatorComponent>());

    return nullptr;
}
