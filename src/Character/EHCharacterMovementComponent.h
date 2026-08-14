#pragma once
#include "core/EHActorComponent.h"
#include "animation/EHAnimatorComponent.h"

class EHCharacterMovementComponent : public EHActorComponent, public ITickable {
private:
    float maxDesiredSpeed;
    float defaultAcceleration;
    float isInAir;
    EHAnimatorComponent* cachedAnimator;

public:
    EHCharacterMovementComponent() : EHActorComponent(), maxDesiredSpeed(0.f), defaultAcceleration(0.f), isInAir(false),
    cachedAnimator(nullptr) {}
    void Tick(float deltaTime) override;
    void InitializeComponent(EHActor *actr) override;
};