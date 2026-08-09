#pragma once
#include "EHActor.h"

class EHActorComponent
{
private:
    EHActor* actor;

public:
    EHActorComponent() : actor(nullptr) {}
    virtual ~EHActorComponent() = default;
    virtual void InitializeComponent(EHActor* actr);
};