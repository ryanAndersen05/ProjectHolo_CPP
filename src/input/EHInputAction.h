#pragma once
#include "library/EHEvent.h"
#include "library/EHLibrary.h"
#include "SFML/Window/Joystick.hpp"
#include "SFML/Window/Keyboard.hpp"


enum class EInputType {
    Keyboard,
    KeyboardAxis,
    Joystick,
    JoystickAxis,
};

NLOHMANN_JSON_SERIALIZE_ENUM(EInputType, {
{EInputType::Keyboard, "Keyboard"},
{EInputType::KeyboardAxis, "KeyboardAxis"},
{EInputType::Joystick, "Joystick"},
{EInputType::JoystickAxis, "JoystickAxis"}});

namespace sf::Joystick {
    NLOHMANN_JSON_SERIALIZE_ENUM(sf::Joystick::Axis, {
    {sf::Joystick::Axis::X, "X"},
    {sf::Joystick::Axis::Y, "Y"},
    {sf::Joystick::Axis::Z, "Z"},
    {sf::Joystick::Axis::R, "R"},
    {sf::Joystick::Axis::U, "U"},
    {sf::Joystick::Axis::V, "V"},
    {sf::Joystick::Axis::PovX, "PovX"},
    {sf::Joystick::Axis::PovY, "PovY"}});
}

namespace sf::Keyboard {
    NLOHMANN_JSON_SERIALIZE_ENUM(sf::Keyboard::Key, {
    {sf::Keyboard::Key::A, "A"},
    {sf::Keyboard::Key::B, "B"},
    {sf::Keyboard::Key::C, "C"},
    {sf::Keyboard::Key::D, "D"},
    {sf::Keyboard::Key::E, "E"},
    {sf::Keyboard::Key::F, "F"},
    {sf::Keyboard::Key::G, "G"},
    {sf::Keyboard::Key::H, "H"},
    {sf::Keyboard::Key::I, "I"},
    {sf::Keyboard::Key::J, "J"},
    {sf::Keyboard::Key::K, "K"},
    {sf::Keyboard::Key::L, "L"},
    {sf::Keyboard::Key::M, "M"},
    {sf::Keyboard::Key::N, "N"},
    {sf::Keyboard::Key::O, "O"},
    {sf::Keyboard::Key::P, "P"},
    {sf::Keyboard::Key::Q, "Q"},
    {sf::Keyboard::Key::R, "R"},
    {sf::Keyboard::Key::S, "S"},
    {sf::Keyboard::Key::T, "T"},
    {sf::Keyboard::Key::U, "U"},
    {sf::Keyboard::Key::V, "V"},
    {sf::Keyboard::Key::W, "W"},
    {sf::Keyboard::Key::X, "X"},
    {sf::Keyboard::Key::Y, "Y"}});
}


struct FInputContext {
private:
    float value;
    unsigned int controllerId;

public:
    FInputContext(float value, unsigned int controllerId) : value(value), controllerId(controllerId) {}
    [[nodiscard]] float GetValue() const { return value;};
    [[nodiscard]] bool GetValueAsButton() const { return value > 50.f; };
    [[nodiscard]] bool IsDeviceKeyboard() const { return controllerId == 0; }
};


class EHInputKey {
private:
    float value;
public:
    [[nodiscard]] float GetValue() const { return value; }
    void SetValue(float value);
    EHInputKey() : value(0.f) {}
};

class EHKeyboardKey : public EHInputKey {
private:
    std::uint32_t delegateId;
protected:
    bool isPositivePressed;
    bool isNegativePressed;
public:
    sf::Keyboard::Key positiveKey;
    sf::Keyboard::Key negativeKey;

    EHKeyboardKey(sf::Keyboard::Key positive, sf::Keyboard::Key negative = sf::Keyboard::Key::Unknown) : delegateId(0), isPositivePressed(false), isNegativePressed(false), positiveKey(positive), negativeKey(negative) {};
    bool OnKeyboardPressed(sf::Keyboard::Key key, bool isPressed);
};

class EHJoystickButton : public EHInputKey {
    unsigned int buttonId;
public:
    EHJoystickButton(unsigned int buttonId) : buttonId(buttonId) {}
    bool OnButtonPressed(unsigned int buttonId, bool isPressed);
};

class EHJoystickAxis : public EHInputKey {
private:
    sf::Joystick::Axis axisId;
    bool inverted;
public:
    EHJoystickAxis(sf::Joystick::Axis axisIs, bool inverted) : axisId(axisIs), inverted(inverted) {};
    bool OnAxisUpdated(sf::Joystick::Axis axis, float value);
};

struct FInputAction {
    EHDelegate<FInputContext> started;
    EHDelegate<FInputContext> cancelled;
    EHDelegate<FInputContext> performed;
public:
    FInputAction();

private:
    float value;
    FName name;
    std::vector<EHKeyboardKey> keys;
    std::vector<EHJoystickButton> buttons;
    std::vector<EHJoystickAxis> axes;
    
    void UpdateValue(unsigned int deviceId);
    friend void from_json(const nlohmann::json& j, FInputAction& action);
public:
    void UpdateKeyboardKey(sf::Keyboard::Key key, bool isPressed);
    void UpdateJoystickButton(unsigned int joystickId, unsigned int buttonId, bool isPressed);
    void UpdateJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axisId, float newValue);
    [[nodiscard]] const FName& GetName() const { return name; };
};