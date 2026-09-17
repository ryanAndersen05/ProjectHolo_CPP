#include "EHController.h"

EHController::EHController() : EHActor() {
    OnInputUpdatedEvent = EHDelegate<EButton, bool, int>();
}

void EHController::TickController(int frame) {
    EButton previousButton = GetButtonAtFrame(EHMath::SafeMod(frame - 1, ButtonLength));
    EButton currentButton = GetButtonAtFrame(EHMath::SafeMod(frame, ButtonLength));

    auto deltaButton = currentButton ^ previousButton;
    if (deltaButton == EButton::None) {
        return;
    }
    auto deltaPress = deltaButton & currentButton;
    auto deltaRelease = deltaButton & ~currentButton;
    if (deltaPress != EButton::None) {
        OnInputUpdatedEvent.Invoke(deltaPress, true, frame);
    }
    if (deltaRelease != EButton::None) {
        OnInputUpdatedEvent.Invoke(deltaRelease, false, frame);
    }
}

void EHController::AssignButton(EButton button, int frame) {
    int adjustedIndex = EHMath::SafeMod(frame, ButtonLength);
    inputHistory[adjustedIndex] = button;
}

EButton EHController::GetButtonAtFrame(int frame) const {
    int adjustedFrame = EHMath::SafeMod(frame, ButtonLength);
    return inputHistory[adjustedFrame];
}

int EHController::GetHorizontalAxis(int frame) const {
    EButton button = GetButtonAtFrame(frame);
    int axis = 0;
    axis += (button & EButton::Right) != EButton::None ? 1 : 0;
    axis -= (button & EButton::Left) != EButton::None ? 1 : 0;
    return axis;
}

int EHController::GetVerticalAxis(int frame) const {
    EButton button = GetButtonAtFrame(frame);
    int axis = 0;
    axis += (button & EButton::Up) != EButton::None ? 1 : 0;
    axis -= (button & EButton::Down) != EButton::None ? 1 : 0;
    return axis;
}
