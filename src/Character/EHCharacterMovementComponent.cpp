#include "EHCharacterMovementComponent.h"
#include "factory/EHActorComponentFactory.h"

void EHCharacterMovementComponent::InitializeComponent(EHActor *actr)  {
     EHActorComponent::InitializeComponent(actr);
     cachedAnimator = dynamic_cast<EHAnimatorComponent *>(actr->
         GetActorComponent(EHActorComponentFactory::CharacterMovementComponentId));
}

void EHCharacterMovementComponent::Tick(float) {
    // float yPos = GetActorPosition().y;
    // if (cachedAnimator) {
    // }
}
