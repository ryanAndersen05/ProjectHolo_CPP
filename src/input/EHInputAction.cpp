#include "EHInputAction.h"
#include "EHInputSystem.h"

void EHInputKey::SetValue(float value) {
    this->value = value;
}

bool EHKeyboardKey::OnKeyboardPressed(sf::Keyboard::Key key, bool isPressed) {
    if (key == positiveKey) {
        isPositivePressed  = isPressed;
    }
    else if (key == negativeKey) {
        isNegativePressed = isPressed;
    }
    else return false;
    float oldValue = GetValue();
    SetValue((static_cast<float>(isPositivePressed) * 100.f) + (static_cast<float>(isNegativePressed) * 100.f));
    return oldValue != GetValue();
}

bool EHJoystickButton::OnButtonPressed(unsigned int button, bool isPressed) {
    if (button != buttonId) return false;
    float oldValue = GetValue();
    SetValue(isPressed ? 0.f : 100.f);
    return oldValue != GetValue();
}

bool EHJoystickAxis::OnAxisUpdated(sf::Joystick::Axis axis, float value) {
    if (axisId != axis) return false;
    float oldValue = GetValue();
    SetValue(value);
    return oldValue != GetValue();
}

FInputAction::FInputAction() {
    value = 0;
    name = FName();
    started = EHDelegate<FInputContext>();
    cancelled = EHDelegate<FInputContext>();
    performed = EHDelegate<FInputContext>();
}


void FInputAction::UpdateValue(float inputValue) {
    FInputContext context(inputValue, 0);
    if (this->value <= 0.1f && inputValue > 0.1f) {
        started.Invoke(context);
    }
    if (this->value > 0.1f && inputValue <= 0.1f) {
        cancelled.Invoke(context);
    }
    performed.Invoke(context);
    this->value = inputValue;
}

void FInputAction::UpdateKeyboardKey(sf::Keyboard::Key key, bool isPressed) {
    float oldValue = value;
    for (EHKeyboardKey& input : keys) {
        if (input.OnKeyboardPressed(key, isPressed)) {
            value = isPressed ? 100.f : 0.f;
            FInputContext context(value, EHInputSystem::KeyboardId);
            if (oldValue == 0.0f) started.Invoke(context);
            if (value == 0.0f) cancelled.Invoke(context);
            performed.Invoke(context);
            return;
        }
    }
}

void FInputAction::UpdateJoystickButton(unsigned int joystickId, unsigned int buttonId, bool isPressed) {
    float oldValue = value;
    for (EHJoystickButton& button : buttons) {
        if (button.OnButtonPressed(buttonId, isPressed)) {
            value = isPressed ? 100.f : 0.f;
            FInputContext context(value, joystickId);
            if (oldValue == 0.0f) started.Invoke(context);
            if (value == 0.0f) cancelled.Invoke(context);
            performed.Invoke(context);
            return;
        }
    }
}

void FInputAction::UpdateJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axisId, float newValue) {
    float adjustedValue = abs(newValue) < 10.f ? 0.f : newValue;
    float oldValue = value;
    for (EHJoystickAxis& axis : axes) {
        if (axis.OnAxisUpdated(axisId, adjustedValue)) {
            value = adjustedValue;
            FInputContext context(value, joystickId);
            if (oldValue == 0.0f) started.Invoke(context);
            if (value == 0.0f) cancelled.Invoke(context);
            performed.Invoke(context);
            return;
        }
    }
}

void from_json(const nlohmann::json& j, FInputAction& action) {
    action.name = j.at("name").get<FName>();
    json inputArray = j.at("inputs");
    for (const auto& input : inputArray) {
        switch (input.at("inputType").get<EInputType>()) {
            case EInputType::Joystick:
                action.buttons.emplace_back(EHJoystickButton(input.at("button").get<unsigned int>()));
                break;
            case EInputType::JoystickAxis:
                action.axes.emplace_back(EHJoystickAxis(input.at("axis").get<sf::Joystick::Axis>()));
                break;
            case EInputType::Keyboard:
                action.keys.emplace_back(EHKeyboardKey(input.at("positive").get<sf::Keyboard::Key>()));
                break;
            case EInputType::KeyboardAxis:
                action.keys.emplace_back(EHKeyboardKey(input.at("positive").get<sf::Keyboard::Key>(),
                    input.at("negative").get<sf::Keyboard::Key>()));
                break;
            default:
                break;
        }
    }
}