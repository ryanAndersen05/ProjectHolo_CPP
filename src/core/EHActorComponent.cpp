#include "EHActorComponent.h"
#include "EHActor.h"

void EHActorComponent::InitializeComponent(EHActor* actr)
{
    this->actor = actr;
}