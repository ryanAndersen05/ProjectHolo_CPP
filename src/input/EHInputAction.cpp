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
    SetValue(isPressed ? 100.f : 0.f);
    return oldValue != GetValue();
}

bool EHJoystickAxis::OnAxisUpdated(sf::Joystick::Axis axis, float value) {
    if (axisId != axis) return false;
    float oldValue = GetValue();
    float adjustedValue = (inverted ? -1.f : 1.f) * value;
    SetValue(adjustedValue);
    return oldValue != GetValue();
}

FInputAction::FInputAction() {
    value = 0;
    name = FName();
    started = EHDelegate<FInputContext>();
    cancelled = EHDelegate<FInputContext>();
    performed = EHDelegate<FInputContext>();
}


void FInputAction::UpdateValue(unsigned int deviceId) {
    float previousValue = value;
    value = 0;
    for (const EHJoystickAxis& axis : axes) value += axis.GetValue();
    for (const EHJoystickButton& button : buttons) value +=  button.GetValue();
    for (const EHKeyboardKey key : keys) value += key.GetValue();


    FInputContext context(value, deviceId);
    if (previousValue <= 0.1f && value > 0.1f) {
        started.Invoke(context);
    }
    if (previousValue > 0.1f && value <= 0.1f) {
        cancelled.Invoke(context);
    }
    performed.Invoke(context);
}

void FInputAction::UpdateKeyboardKey(sf::Keyboard::Key key, bool isPressed) {
    for (EHKeyboardKey& input : keys) {
        if (input.OnKeyboardPressed(key, isPressed)) {
            UpdateValue(EHInputSystem::KeyboardId);
        }
    }
}

void FInputAction::UpdateJoystickButton(unsigned int joystickId, unsigned int buttonId, bool isPressed) {
    for (EHJoystickButton& button : buttons) {
        if (button.OnButtonPressed(buttonId, isPressed)) {
            UpdateValue(joystickId);
        }
    }
}

void FInputAction::UpdateJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axisId, float newValue) {
    float adjustedValue = abs(newValue) < 10.f ? 0.f : newValue;
    for (EHJoystickAxis& axis : axes) {
        if (axis.OnAxisUpdated(axisId, adjustedValue)) {
            UpdateValue(joystickId);
        }
    }
}

void from_json(const nlohmann::json& j, FInputAction& action) {
    action.name = j.at("name").get<FName>();
    json inputArray = j.at("inputs");
    bool inverted;
    for (const auto& input : inputArray) {
        switch (input.at("inputType").get<EInputType>()) {
            case EInputType::Joystick:
                action.buttons.emplace_back(EHJoystickButton(input.at("button").get<unsigned int>()));
                break;
            case EInputType::JoystickAxis:
                inverted = false;
                if (input.at("inverted").is_boolean()) {
                    inverted = input.at("inverted").get<bool>();
                }
                action.axes.emplace_back(EHJoystickAxis(input.at("axis").get<sf::Joystick::Axis>(), inverted));
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