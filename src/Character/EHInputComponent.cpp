#include "EHInputComponent.h"

#include "core/EHGameInstance.h"
#include "gamemode/EHGameModeFighting.h"

const FName EHInputComponent::ButtonTrigger = FName("button");
const FName EHInputComponent::LightAttackTrigger = FName("light");
const FName EHInputComponent::MediumAttackTrigger = FName("medium");
const FName EHInputComponent::HeavyAttackTrigger = FName("heavy");
const FName EHInputComponent::SpecialAttackTrigger = FName("special");

void EHInputComponent::InitializeComponent(EHActor *actr) {
    EHActorComponent::InitializeComponent(actr);
    cachedAnimator = dynamic_cast<EHAnimatorComponent*>(actr->GetActorComponent(FName("animator")));
}

void EHInputComponent::Tick(float) {
    if (bufferedInputs.empty()) return;
    for (int i = static_cast<int>(bufferedInputs.size()) - 1; i >= 0; --i) {
        if (bufferedInputs[i].second <= 0) {
            RemoveBufferedInput(bufferedInputs[i].first);
            continue;
        }
        bufferedInputs[i].second--;
    }
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

void EHInputComponent::OnInputUpdatedEvent(EButton deltaButton, bool isPressed, int frame) {
    EButton horizontalDelta = static_cast<EButton>((EButton::Left | EButton::Right) & deltaButton);
    EButton verticalDelta = static_cast<EButton>((EButton::Up | EButton::Down) & deltaButton);
    if (horizontalDelta != EButton::None) {
        cachedAnimator->SetInt(FName("hInput"), cachedController->GetHorizontalAxis(frame));
    }
    if (verticalDelta != EButton::None) {
        cachedAnimator->SetInt(FName("vInput"), cachedController->GetVerticalAxis(frame));
    }
    if (isPressed) {
        if ((deltaButton & EButton::Light) != EButton::None) {
            ApplyBufferedInput(ButtonTrigger);
            ApplyBufferedInput(LightAttackTrigger);
        }
        if ((deltaButton & EButton::Medium) != EButton::None) {
            ApplyBufferedInput(ButtonTrigger);
            ApplyBufferedInput(MediumAttackTrigger);
        }
        if ((deltaButton & EButton::Heavy) != EButton::None) {
            ApplyBufferedInput(ButtonTrigger);
            ApplyBufferedInput(HeavyAttackTrigger);

        }
        if ((deltaButton & EButton::Special) != EButton::None) {
            ApplyBufferedInput(ButtonTrigger);
            ApplyBufferedInput(SpecialAttackTrigger);
        }
    }
}

void EHInputComponent::ApplyBufferedInput(const FName &input) {
    const auto it = std::find_if(bufferedInputs.begin(), bufferedInputs.end(), [&input](const auto& pair) {
        return pair.first == input;
    });
    if (it == bufferedInputs.end()) {
        bufferedInputs.emplace_back(input, BufferedInputFrames);
    }
    else {
        it->second--;
    }
    cachedAnimator->SetTrigger(input);
}

void EHInputComponent::RemoveBufferedInput(const FName &input) {
    std::erase_if(bufferedInputs, [&input](const auto& pair) {
        return pair.first == input;
    });
    cachedAnimator->ResetTrigger(input);
}
