#pragma once
#include "library/EHEvent.h"
#include <SFML/Window/Event.hpp>

class EHInputSystem {
    static EHInputSystem* instance;
public:
    EHDelegate<sf::Keyboard::Key, bool> OnKeyboardPressedEvent;
    EHDelegate<unsigned int, unsigned int, bool> OnJoystickPressedEvent;
    EHDelegate<unsigned int, sf::Joystick::Axis, float> OnAxisStartedEvent;
    EHDelegate<unsigned int> OnJoystickDisconnectedEvent;
    EHDelegate<unsigned int> OnJoystickConnectedEvent;
    
    EHInputSystem();
    ~EHInputSystem();
    static EHInputSystem* GetInstance() {return instance;}
    void OnKeyboardPressed(sf::Keyboard::Key key, bool isPressed);

    void OnJoystickPressed(unsigned int joystickId, unsigned int button, bool isPressed);
    void OnJoystickAxis(unsigned int joystickId, sf::Joystick::Axis axis, float axisValue);
    void OnJoystickConnected(unsigned int joystickId);
    void OnJoystickDisconnected(unsigned int joystickId);
};
