#include "EHActorComponentFactory.h"

#include "camera/EHCamera.h"
#include "character/EHCharacterMovementComponent.h"
#include "character/EHInputComponent.h"
#include "character/EHPaletteComponent.h"
#include "library/EHJsonManager.h"
#include "physics/EHPhyicsComponent.h"
#include "sprite/EHSpriteComponent.h"


const FName EHActorComponentFactory::SpriteComponentId = FName("sprite");
const FName EHActorComponentFactory::PhysicsComponentId = FName("physics");
const FName EHActorComponentFactory::CharacterMovementComponentId = FName("charactermovement");
const FName EHActorComponentFactory::AnimatorComponentId = FName("animator");
const FName EHActorComponentFactory::CameraComponentId = FName("camera");
const FName EHActorComponentFactory::ColorPaletteComponentId = FName("palette");
const FName EHActorComponentFactory::InputComponentId = FName("input");


EHActorComponent* EHActorComponentFactory::CreateActorComponent(const FName& componentType, const json& componentData) {

    if (componentType == SpriteComponentId) return new EHSpriteComponent(componentData.get<EHSpriteComponent>());
    if (componentType == PhysicsComponentId) return new EHPhysicsComponent(componentData.get<EHPhysicsComponent>());
    if (componentType == CharacterMovementComponentId) return new EHCharacterMovementComponent(componentData.get<EHCharacterMovementComponent>());
    if (componentType == AnimatorComponentId) return new EHAnimatorComponent(componentData.get<EHAnimatorComponent>());
    if (componentType == CameraComponentId) return new EHCamera(componentData.get<EHCamera>());
    if (componentType == ColorPaletteComponentId) return new EHPaletteComponent();
    if (componentType == InputComponentId) return new EHInputComponent();
    std::cout << "CreateActorComponent() - Invalid Id: " << componentType.GetKey() << std::endl;
    return nullptr;
}
