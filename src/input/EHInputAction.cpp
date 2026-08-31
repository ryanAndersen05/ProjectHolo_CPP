#include "EHInputAction.h"
#include "EHInputSystem.h"

void EHInputKey::SetValue(float value) {
    this->value = value;

}

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
    SetValue((static_cast<float>(isPositivePressed) * 100.f) + (static_cast<float>(isNegativePressed) * 100.f));
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
    SetValue(isPressed ? 0.f : 100.f);
}

FInputAction::~FInputAction() {
    for (EHInputKey* input : inputs) {
        delete input;
    }
}

void FInputAction::InitializeInputs() {
    for (EHInputKey* input : inputs) {
        input->SetInputAction(this);
    }
}

void FInputAction::UpdateValue(float value) {
    FInputContext context(value);
    if (this->value <= 0.1f && value > 0.1f) {
        started.Invoke(context);
    }
    if (this->value > 0.1f && value <= 0.1f) {
        cancelled.Invoke(context);
    }
    performed.Invoke(context);
    this->value = value;
}

void from_json(const nlohmann::json& j, FInputAction& action) {
    action.name = j.at("name").get<FName>();
    json inputArray = j.at("inputs");
    for (const auto& input : inputArray) {
        switch (input.at("inputType").get<EInputType>()) {
            case EInputType::Joystick:
                action.inputs.push_back(new EHJoystickButton(input.at("button").get<unsigned int>()));
                break;
            default:
                break;
        }
    }
}