#include "EHInputComponent.h"

#include "core/EHGameInstance.h"
#include "gamemode/EHGameModeFighting.h"


void EHInputComponent::InitializeComponent(EHActor *actr) {
    EHActorComponent::InitializeComponent(actr);
    cachedAnimator = dynamic_cast<EHAnimatorComponent*>(actr->GetActorComponent(FName("animator")));
}

void EHInputComponent::InitializeController(EHController *controller) {
    if (!controller) return;
    cachedController = controller;
    controllerHandle = controller->OnInputUpdatedEvent.AddListener([this](EButton button, bool isPressed, int frame) {
        OnInputUpdatedEvent(button, isPressed, frame);
    });
}

void EHInputComponent::UninitializeController(EHController *controller) {
    if (!controller) return;
    cachedController = nullptr;
    controller->OnInputUpdatedEvent.RemoveListener(controllerHandle);
}

void EHInputComponent::OnInputUpdatedEvent(EButton deltaButton, bool, int frame) {
    EButton horizontalDelta = static_cast<EButton>((EButton::Left | EButton::Right) & deltaButton);
    EButton verticalDelta = static_cast<EButton>((EButton::Up | EButton::Down) & deltaButton);
    if (horizontalDelta != EButton::None) {
        cachedAnimator->SetInt(FName("hInput"), cachedController->GetHorizontalAxis(frame));
    }
    if (verticalDelta != EButton::None) {
        cachedAnimator->SetInt(FName("vInput"), cachedController->GetVerticalAxis(frame));
    }
}
