#include "EHInputMap.h"

#include "EHInputSystem.h"

EHInputMap::EHInputMap() {
    keyboardDelegateId = EHInputSystem::GetInstance()->OnKeyboardPressedEvent.AddListener([this](sf::Keyboard::Key key, bool isPressed) {
        OnKeyboardEvent(key, isPressed);
    });
    joystickDelegateId = EHInputSystem::GetInstance()->OnJoystickPressedEvent.AddListener([this](unsigned int joystickId, unsigned int joystickButton, bool isPressed) {
        OnJoystickButtonEvent(joystickId, joystickButton, isPressed);
    });
    joystickAxisDelegateId = EHInputSystem::GetInstance()->OnAxisStartedEvent.AddListener([this](unsigned int joystickId, sf::Joystick::Axis axis, float value) {
        OnAxisEvent(joystickId, axis, value);
    });
}

EHInputMap::~EHInputMap() {
    EHInputSystem::GetInstance()->OnKeyboardPressedEvent.RemoveListener(keyboardDelegateId);
    EHInputSystem::GetInstance()->OnJoystickPressedEvent.RemoveListener(joystickDelegateId);
    EHInputSystem::GetInstance()->OnAxisStartedEvent.RemoveListener(joystickAxisDelegateId);
}

bool EHInputMap::ContainsId(const unsigned int id) const {
    if (deviceIds.empty()) return true;
    for (unsigned int i : deviceIds) {
        if (i == id) return true;
    }
    return false;
}

FInputAction* EHInputMap::FindAction(const FName &actionName) {
    for (FInputAction& action : actions) {
        if (action.GetName() == actionName) {
            return &action;
        }
    }
    return nullptr;
}

void EHInputMap::OnKeyboardEvent(sf::Keyboard::Key key, bool isPressed) {
    if (!ContainsId(EHInputSystem::KeyboardId)) return;
    for (FInputAction& action : actions) {
        action.UpdateKeyboardKey(key, isPressed);
    }
}

void EHInputMap::OnJoystickButtonEvent(unsigned int joystickId, unsigned int joystickButton, bool isPressed) {
    if (!ContainsId(joystickId)) return;
    for (FInputAction& action : actions) {
        action.UpdateJoystickButton(joystickId, joystickButton, isPressed);
    }
}

void EHInputMap::OnAxisEvent(unsigned int joystickId, sf::Joystick::Axis axis, float value) {
    if (!ContainsId(joystickId)) return;
    for (FInputAction& action : actions) {
        action.UpdateJoystickAxis(joystickId, axis, value);
    }
}

void from_json(const json& j, EHInputMap& inputMap) {
    json actionList = j.at("actions");
    for (auto& action : actionList) {
        inputMap.actions.push_back(action.get<FInputAction>());
    }
}