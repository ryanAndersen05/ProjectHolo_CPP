#pragma once
#include "animation/EHAnimatorComponent.h"
#include "core/EHActorComponent.h"
#include "core/EHController.h"
#include "input/EHDirectionalInputTree.h"
#include <optional>

class EHInputComponent : public EHActorComponent, public ITickable {
private:
    static const FName HorizontalInputParameter;
    static const FName VerticalInputParameter;
    static const FName ButtonTrigger;
    static const FName LightAttackTrigger;
    static const FName MediumAttackTrigger;
    static const FName HeavyAttackTrigger;
    static const FName SpecialAttackTrigger;
    static const FName DoubleForwardTrigger;
    static const FName DoubleBackTrigger;
    static const FName DoubleDownTrigger;
    static const FName QuarterCircleForwardTrigger;
    static const FName QuarterCircleBackTrigger;
    static const FName DoubleQuarterCircleForwardTrigger;
    static constexpr int BufferedInputFrames = 8;

    EHAnimatorComponent* cachedAnimator;
    EHController* cachedController;
    std::uint32_t controllerHandle;
    std::vector<std::pair<FName, int>> bufferedInputs;
    std::optional<int> firstInputFrame;
    std::optional<int> lastDirectionalFrame;
    void UpdateDirectionalInput(int frame);
    void PerformDirectionalInput(EDirectionalMotion motion, int frame);

    void OnInputUpdatedEvent(EButton deltaButton, bool isPressed, int frame);
    void ApplyBufferedInput(const FName& input);
    void RemoveBufferedInput(const FName& input);
public:
    static constexpr int DirectionalInputFrames = 20;
    EHDelegate<EDirectionalMotion, int> OnDirectionalInputEvent;

    EHInputComponent() : EHActorComponent(), cachedAnimator(nullptr), cachedController(nullptr), controllerHandle(0) {}
    void Tick(float deltaTime) override;
    void InitializeComponent(EHActor *actr) override;
    void InitializeController(EHController* controller);
    void UninitializeController(EHController* controller);
};
