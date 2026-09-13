#include "EHPlayerController.h"
#include <bitset>
#include <iostream>
#include "core/EHGameInstance.h"
#include "library/EHLibrary.h"
#include <cmath>

FName const EHPlayerController::LightAttackAction = FName("light");
FName const EHPlayerController::MediumAttackAction = FName("medium");
FName const EHPlayerController::HeavyAttackAction = FName("heavy");
FName const EHPlayerController::SpecialAttackAction = FName("special");
FName const EHPlayerController::MoveHorizontalAction = FName("move_horizontal");
FName const EHPlayerController::MoveVerticalAction = FName("move_vertical");

EHPlayerController::EHPlayerController() : EHController(), cachedButton(EButton::None), previousButton(EButton::None) {
    if (!EHGameInstance::LoadAsset(FName("default_game_input"), inputMap)) {
        std::cout << "EHPlayerController() - Invalid Player Game Input Map" << std::endl;
        return;
    }
    FInputAction* lightAction = inputMap.FindAction(LightAttackAction);
    lightAction->started.AddListener([this](const FInputContext& inputContext) {
        OnLightButtonAction(inputContext);
    });
    lightAction->cancelled.AddListener([this](const FInputContext& inputContext) {
        OnLightButtonAction(inputContext);
    });
    FInputAction* mediumAction = inputMap.FindAction(MediumAttackAction);
    mediumAction->started.AddListener([this](const FInputContext& inputContext) {
        OnMediumButtonAction(inputContext);
    });
    mediumAction->cancelled.AddListener([this](const FInputContext& inputContext) {
        OnMediumButtonAction(inputContext);
    });
    FInputAction* heavyAction = inputMap.FindAction(HeavyAttackAction);
    heavyAction->started.AddListener([this](const FInputContext& inputContext) {
        OnHeavyButtonAction(inputContext);
    });
    heavyAction->cancelled.AddListener([this](const FInputContext& inputContext) {
        OnHeavyButtonAction(inputContext);
    });
    FInputAction* specialAction = inputMap.FindAction(SpecialAttackAction);
    specialAction->started.AddListener([this](const FInputContext& inputContext) {
        OnSpecialButtonAction(inputContext);
    });
    specialAction->cancelled.AddListener([this](const FInputContext& inputContext) {
        OnSpecialButtonAction(inputContext);
    });
    FInputAction* moveHorizontalAction = inputMap.FindAction(MoveHorizontalAction);
    moveHorizontalAction->started.AddListener([this](const FInputContext& inputContext) {
        OnMoveHorizontalAction(inputContext);
    });
    moveHorizontalAction->cancelled.AddListener([this](const FInputContext& inputContext) {
        OnMoveHorizontalAction(inputContext);
    });
    moveHorizontalAction->performed.AddListener([this](const FInputContext& inputContext) {
        OnMoveHorizontalAction(inputContext);
    });
    FInputAction* moveVerticalAction = inputMap.FindAction(MoveVerticalAction);
    moveVerticalAction->started.AddListener([this](const FInputContext& inputContext) {
        OnMoveVerticalAction(inputContext);
    });
    moveVerticalAction->cancelled.AddListener([this](const FInputContext& inputContext) {
        OnMoveVerticalAction(inputContext);
    });
    moveVerticalAction->performed.AddListener([this](const FInputContext& inputContext) {
        OnMoveVerticalAction(inputContext);
    });
}

EHPlayerController::~EHPlayerController() {

}

void EHPlayerController::ModifyCachedButton(EButton button, bool isPressed) {
    if (isPressed) {
        cachedButton = static_cast<EButton>(cachedButton | button);
    }
    else {
        cachedButton = static_cast<EButton>(cachedButton & ~button);
    }
    if (previousButton!=cachedButton) {
        // std::cout << std::bitset<8>(cachedButton) << std::endl;
        previousButton = cachedButton;
    }
}

void EHPlayerController::OnMoveHorizontalAction(const FInputContext &inputContext) {
    float value = inputContext.GetValue();
    if (abs(value) < JoystickDeadZone) {
        EButton button = static_cast<EButton>(EButton::Right | EButton::Left);
        ModifyCachedButton(button, false);
        return;
    }
    ModifyCachedButton(EButton::Right, value > 0);
    ModifyCachedButton(EButton::Left, value < 0);
}

void EHPlayerController::OnMoveVerticalAction(const FInputContext &inputContext) {
    float value = inputContext.GetValue();
    if (abs(value) < JoystickDeadZone) {
        EButton button = static_cast<EButton>(EButton::Up | EButton::Down);
        ModifyCachedButton(button, false);
    }
    ModifyCachedButton(EButton::Up, value > 0);
    ModifyCachedButton(EButton::Down, value < 0);
}
