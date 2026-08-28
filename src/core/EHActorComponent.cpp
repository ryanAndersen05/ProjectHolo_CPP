#include "EHActorComponent.h"
#include "EHActor.h"
#include <iostream>

void EHActorComponent::InitializeComponent(EHActor* actr)
{
    this->actor = actr;
}

EHActorComponent *EHActorComponent::GetComponentById(const FName &componentName) const {
    if (!actor) {
        std::cout << "No Actor found. This shouldn't happen" << std::endl;
        return nullptr;
    }

    return actor->GetActorComponent(componentName);
}
