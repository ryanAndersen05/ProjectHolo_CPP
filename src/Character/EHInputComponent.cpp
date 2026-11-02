#include "EHInputComponent.h"
#include "factory/EHActorComponentFactory.h"

#include <algorithm>
#include <array>

const FName EHInputComponent::HorizontalInputParameter = FName("hInput");
const FName EHInputComponent::VerticalInputParameter = FName("vInput");
const FName EHInputComponent::ButtonTrigger = FName("button");
const FName EHInputComponent::LightAttackTrigger = FName("light");
const FName EHInputComponent::MediumAttackTrigger = FName("medium");
const FName EHInputComponent::HeavyAttackTrigger = FName("heavy");
const FName EHInputComponent::SpecialAttackTrigger = FName("special");
const FName EHInputComponent::DoubleForwardTrigger = FName("doubleForward");
const FName EHInputComponent::DoubleBackTrigger = FName("doubleBack");
const FName EHInputComponent::DoubleDownTrigger = FName("doubleDown");
const FName EHInputComponent::QuarterCircleForwardTrigger = FName("qcf");
const FName EHInputComponent::QuarterCircleBackTrigger = FName("qcb");
const FName EHInputComponent::DoubleQuarterCircleForwardTrigger = FName("doubleQcf");

void EHInputComponent::InitializeComponent(EHActor *actr) {
    EHActorComponent::InitializeComponent(actr);
    cachedAnimator = dynamic_cast<EHAnimatorComponent*>(actr->GetActorComponent(EHActorComponentFactory::AnimatorComponentId));
}

void EHInputComponent::Tick(float) {
    if (bufferedInputs.empty()) return;
    for (int i = static_cast<int>(bufferedInputs.size()) - 1; i >= 0; --i) {
        if (--bufferedInputs[i].second <= 0) {
            RemoveBufferedInput(bufferedInputs[i].first);
            continue;
        }
    }
}

void EHInputComponent::InitializeController(EHController *controller) {
    if (!controller) return;
    if (cachedController == controller) return;
    if (cachedController) UninitializeController(cachedController);
    cachedController = controller;
    controllerHandle = controller->OnInputUpdatedEvent.AddListener([this](EButton button, bool isPressed, int frame) {
        OnInputUpdatedEvent(button, isPressed, frame);
    });
}

void EHInputComponent::UninitializeController(EHController *controller) {
    if (!controller || cachedController != controller) return;
    while (!bufferedInputs.empty()) RemoveBufferedInput(bufferedInputs.back().first);
    firstInputFrame.reset();
    lastDirectionalFrame.reset();
    cachedController = nullptr;
    controller->OnInputUpdatedEvent.RemoveListener(controllerHandle);
}

void EHInputComponent::OnInputUpdatedEvent(EButton deltaButton, bool isPressed, int frame) {
    if (!firstInputFrame) firstInputFrame = std::max(0, frame - 1);
    const EButton directions = EButton::Left | EButton::Right | EButton::Up | EButton::Down;
    if ((deltaButton & directions) != EButton::None) UpdateDirectionalInput(frame);
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
        it->second = BufferedInputFrames;
    }
    if (cachedAnimator) cachedAnimator->SetTrigger(input);
}

void EHInputComponent::RemoveBufferedInput(const FName &input) {
    std::erase_if(bufferedInputs, [&input](const auto& pair) {
        return pair.first == input;
    });
    if (cachedAnimator) cachedAnimator->ResetTrigger(input);
}

void EHInputComponent::UpdateDirectionalInput(int frame) {
    if (lastDirectionalFrame == frame) return;
    lastDirectionalFrame = frame;
    const int horizontal = cachedController->GetHorizontalAxis(frame);
    const int vertical = cachedController->GetVerticalAxis(frame);
    if (cachedAnimator) {
        cachedAnimator->SetInt(HorizontalInputParameter, horizontal);
        cachedAnimator->SetInt(VerticalInputParameter, vertical);
    }
    const auto current = EHDirectionalInputTree::ToDirection(horizontal, vertical, false);
    const auto previous = frame > 0 ? EHDirectionalInputTree::ToDirection(
        cachedController->GetHorizontalAxis(frame - 1), cachedController->GetVerticalAxis(frame - 1), false)
        : EDirectionalInput::Neutral;
    if (current == previous) return;

    // Interpret the complete window using current facing, matching the original game.
    const bool facingLeft = GetActorScale().x < 0.f;
    std::array<EDirectionalInput, DirectionalInputFrames> history{};
    std::size_t count = 0;
    const int oldest = std::max(*firstInputFrame, frame - DirectionalInputFrames + 1);
    for (int sample = frame; sample >= oldest; --sample) {
        const auto direction = EHDirectionalInputTree::ToDirection(
            cachedController->GetHorizontalAxis(sample), cachedController->GetVerticalAxis(sample), facingLeft);
        if (count == 0 || direction != history[count - 1]) history[count++] = direction;
    }
    const auto motion = EHDirectionalInputTree::GetDefault().Match({history.data(), count});
    if (motion != EDirectionalMotion::None) PerformDirectionalInput(motion, frame);
}

void EHInputComponent::PerformDirectionalInput(EDirectionalMotion motion, int frame) {
    const FName* trigger = nullptr;
    switch (motion) {
        case EDirectionalMotion::DoubleForward: trigger = &DoubleForwardTrigger; break;
        case EDirectionalMotion::DoubleBack: trigger = &DoubleBackTrigger; break;
        case EDirectionalMotion::DoubleDown: trigger = &DoubleDownTrigger; break;
        case EDirectionalMotion::QuarterCircleForward: trigger = &QuarterCircleForwardTrigger; break;
        case EDirectionalMotion::QuarterCircleBack: trigger = &QuarterCircleBackTrigger; break;
        case EDirectionalMotion::DoubleQuarterCircleForward: trigger = &DoubleQuarterCircleForwardTrigger; break;
        case EDirectionalMotion::None: return;
    }
    ApplyBufferedInput(*trigger);
    OnDirectionalInputEvent.Invoke(motion, frame);
}
