#pragma once
#include "library/EHEvent.h"
#include "library/EHLibrary.h"
#include "SFML/Window/Joystick.hpp"
#include "SFML/Window/Keyboard.hpp"

enum EInputType {
    Keyboard,
    KeyboardAxis,
    Joystick,
    JoystickAxis,
};

struct FInputContext {
private:
    float value;
public:
    FInputContext() : value(0.f) {}
    [[nodiscard]] float GetValue() const { return value;};
    [[nodiscard]] bool GetValueAsButton() const { return value > 50.f; };
};

class EHInputKey {
protected:
    float value;
public:
    [[nodiscard]] float GetValue() const { return value; }
    EHInputKey() : value(0.f) {}
    virtual ~EHInputKey() = default;
};

class EHKeyboardKey : public EHInputKey {
private:
    std::uint32_t delegateId;
protected:
    bool isPositivePressed = false;
    bool isNegativePressed = false;
public:
    sf::Keyboard::Key positiveKey;
    sf::Keyboard::Key negativeKey;

    EHKeyboardKey();
    ~EHKeyboardKey() override;

    void OnKeyboardPressed(sf::Keyboard::Key key, bool isPressed);
};

class EHJoystickButton : public EHInputKey {
    std::uint32_t delegateId;
    unsigned int joyId;
public:
    unsigned int button;
    EHJoystickButton(unsigned int joystickId);
    ~EHJoystickButton() override;

    void OnButtonPressed(unsigned int joystickId, unsigned int buttonId, bool isPressed);
};

class EHJoystickAxis : public EHInputKey {
private:
    sf::Joystick::Axis axis;
public:
    EHJoystickAxis();
    ~EHJoystickAxis() override;
};

struct FInputAction {
    EHDelegate<FInputContext> started;
    EHDelegate<FInputContext> ended;
    EHDelegate<FInputContext> performed;

    unsigned int joystickId;

private:
    FName inputName;
};