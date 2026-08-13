#pragma once
#include "core/EHActorComponent.h"

class EHCharacterMovementComponent : public EHActorComponent, public ITickable {
private:
    float maxDesiredSpeed;
    float defaultAcceleration;

public:
    EHCharacterMovementComponent() : EHActorComponent(), maxDesiredSpeed(0.f), defaultAcceleration(0.f) {}
    void Tick(float deltaTime) override;
};