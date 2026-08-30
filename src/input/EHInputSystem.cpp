#include "EHInputSystem.h"
#include <iostream>

EHInputSystem* EHInputSystem::instance = nullptr;

EHInputSystem::EHInputSystem() {
    OnKeyboardPressedEvent = EHDelegate<sf::Keyboard::Key, bool>();
    OnJoystickPressedEvent = EHDelegate<unsigned int, unsigned int, bool>();
    OnAxisStartedEvent = EHDelegate<unsigned int, sf::Joystick::Axis, float>();
    if (instance) {
        std::cerr << "EHInputSystem() Error. This should only ever be called once per start of the programe" << std::endl;
        return;
    }
    instance = this;
}

EHInputSystem::~EHInputSystem() {
    if (instance != this) {
        std::cerr << "Destroying Input Instance when there is already another one active. Something went wrong" << std::endl;
        return;
    }
    instance = nullptr;
}

void EHInputSystem::OnKeyboardPressed(sf::Keyboard::Key key, bool isPressed) {
    OnKeyboardPressedEvent.Invoke(key, isPressed);
}

void EHInputSystem::OnJoystickPressed(unsigned int joystickId, unsigned int button, bool isPressed) {
    OnJoystickPressedEvent.Invoke(joystickId, button, isPressed);
}

void EHInputSystem::OnJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float axisValue) {
    OnAxisStartedEvent.Invoke(joystickId, axis, axisValue);
}

void EHInputSystem::OnJoystickConnected(unsigned int joystickId) {
    std::cout << "JoystickID: " << joystickId << " Connected" << std::endl;
}

void EHInputSystem::OnJoystickDisconnected(unsigned int joystickId) {
    std::cout << "JoystickID: " << joystickId << " Disconnected" << std::endl;
}
