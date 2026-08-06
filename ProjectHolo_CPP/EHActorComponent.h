#pragma once
#include "EHActor.h"

class EHActorComponent
{
private:
    EHActor* actor;

public:
    virtual void InitializeComponent(EHActor* actor);

protected:

};