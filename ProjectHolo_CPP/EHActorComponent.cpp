#include "EHActorComponent.h"
#include "EHActor.h"

void EHActorComponent::InitializeComponent(EHActor* actor)
{
    this->actor = actor;
}