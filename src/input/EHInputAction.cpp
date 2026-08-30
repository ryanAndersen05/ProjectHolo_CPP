#include "EHInputAction.h"
#include "EHInputSystem.h"



EHKeyboardKey::EHKeyboardKey() : EHInputKey(), isPositivePressed(false), isNegativePressed(false),
positiveKey(sf::Keyboard::Key::Unknown), negativeKey(sf::Keyboard::Key::Unknown) {
    EHInputSystem* inputSystem = EHInputSystem::GetInstance();
    delegateId = inputSystem->OnKeyboardPressedEvent.AddListener(
        [this](sf::Keyboard::Key key, bool isPressed) {
            OnKeyboardPressed(key, isPressed);
        });
}

EHKeyboardKey::~EHKeyboardKey() {
    EHInputSystem* inputSystem = EHInputSystem::GetInstance();
    inputSystem->OnKeyboardPressedEvent.RemoveListener(delegateId);
}

void EHKeyboardKey::OnKeyboardPressed(sf::Keyboard::Key key, bool isPressed) {
    if (key == positiveKey) {
        isPositivePressed  = isPressed;
    }
    else if (key == negativeKey) {
        isNegativePressed = isPressed;
    }
    else return;
    value = (static_cast<float>(isPositivePressed) * 100.f) + (static_cast<float>(isNegativePressed) * 100.f);
}

EHJoystickButton::EHJoystickButton(unsigned int joystickId) : EHInputKey(), joyId(joystickId), button(0) {
    EHInputSystem* inputSystem = EHInputSystem::GetInstance();
    delegateId = inputSystem->OnJoystickPressedEvent.AddListener(
        [this](unsigned int joystickId, unsigned int buttonId, bool isPressed) {
            OnButtonPressed(joystickId, buttonId, isPressed);
        });
}

EHJoystickButton::~EHJoystickButton() {
    EHInputSystem* inputSystem = EHInputSystem::GetInstance();
    inputSystem->OnJoystickPressedEvent.RemoveListener(delegateId);
}

void EHJoystickButton::OnButtonPressed(unsigned int joystickId, unsigned int buttonId, bool isPressed) {
    if (joyId != joystickId) return;
    if (button != buttonId) return;
    value = isPressed ? 0.f : 100.f;
}
