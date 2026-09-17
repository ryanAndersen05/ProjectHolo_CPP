#pragma once
#include "animation/EHAnimatorComponent.h"
#include "core/EHActorComponent.h"
#include "core/EHController.h"

class EHInputComponent : public EHActorComponent {
private:
    EHAnimatorComponent* cachedAnimator;
    EHController* cachedController;
    std::uint32_t controllerHandle;

    void OnInputUpdatedEvent(EButton deltaButton, bool isPressed, int frame);
public:
    EHInputComponent() : EHActorComponent(), cachedAnimator(nullptr), cachedController(nullptr), controllerHandle(0) {}
    void InitializeComponent(EHActor *actr) override;
    void InitializeController(EHController* controller);
    void UninitializeController(EHController* controller);
};
