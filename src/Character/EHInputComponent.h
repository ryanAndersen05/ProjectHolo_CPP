#pragma once
#include "animation/EHAnimatorComponent.h"
#include "core/EHActorComponent.h"
#include "core/EHController.h"

class EHInputComponent : public EHActorComponent, public ITickable {
private:
    static const FName ButtonTrigger;
    static const FName LightAttackTrigger;
    static const FName MediumAttackTrigger;
    static const FName HeavyAttackTrigger;
    static const FName SpecialAttackTrigger;
    static constexpr int BufferedInputFrames = 8;

    EHAnimatorComponent* cachedAnimator;
    EHController* cachedController;
    std::uint32_t controllerHandle;
    std::vector<std::pair<FName, int>> bufferedInputs;

    void OnInputUpdatedEvent(EButton deltaButton, bool isPressed, int frame);
    void ApplyBufferedInput(const FName& input);
    void RemoveBufferedInput(const FName& input);
public:
    EHInputComponent() : EHActorComponent(), cachedAnimator(nullptr), cachedController(nullptr), controllerHandle(0) {}
    void Tick(float deltaTime) override;
    void InitializeComponent(EHActor *actr) override;
    void InitializeController(EHController* controller);
    void UninitializeController(EHController* controller);
};
