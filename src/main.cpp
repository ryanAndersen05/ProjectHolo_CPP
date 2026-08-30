#include <SFML/Graphics.hpp>
#include "library/EHGameData.h"
#include <iostream>
#include "core/EHGameInstance.h"
#include "core/EHLevel.h"
#include "core/EHTime.h"
#include "input/EHInputSystem.h"
#include "library/EHGameSettings.h"

int main()
{
    float accumulator = 0.f;
    float previousTime = 0.f;

    sf::Clock clock;
    EHInputSystem inputSystem;
    sf::RenderWindow window(sf::VideoMode({ EHUserSettings::ScreenWidth, EHUserSettings::ScreenHeight }), "Oshi-Oshi Punch!");
    auto* instance = new EHGameInstance();
    EHGameSettings settings;
    if (!EHGameInstance::LoadAsset<EHGameSettings>(FName("game_settings"), settings)) {
        std::cout << "Failed to load game_settings" << std::endl;
        return -1;
    }
    EHLevel level;
    if (!EHGameInstance::LoadAsset<EHLevel>(settings.initialLevel, level)) {
        std::cout << "Failed to load level" << std::endl;
        return -1;
    }
    instance->InitializeGame(level.worldSettings);


    while (window.isOpen())
    {
        while (const std::optional event = window.pollEvent())
        {
            if (event->is<sf::Event::Closed>())
            {
                window.close();
            }

            if (const auto* keyEvent = event->getIf<sf::Event::KeyPressed>()) {
                inputSystem.OnKeyboardPressed(keyEvent->code, true);;
            }
            if (const auto* keyEvent = event->getIf<sf::Event::KeyReleased>()) {
                inputSystem.OnKeyboardPressed(keyEvent->code, false);
            }
            if (const auto* buttonEvent = event->getIf<sf::Event::JoystickButtonPressed>()) {
                inputSystem.OnJoystickPressed(buttonEvent->joystickId, buttonEvent->button, true);
            }
            if (const auto* buttonEvent = event->getIf<sf::Event::JoystickButtonReleased>()) {
                inputSystem.OnJoystickPressed(buttonEvent->joystickId, buttonEvent->button, false);
            }
            if (const auto* axisEvent = event->getIf<sf::Event::JoystickMoved>()) {
                inputSystem.OnJoystickAxis(axisEvent->joystickId, axisEvent->axis, axisEvent->position);
            }
            if (const auto* connectedEvent = event->getIf<sf::Event::JoystickConnected>()) {
                inputSystem.OnJoystickConnected(connectedEvent->joystickId);
            }
            if (const auto* disconnectedEvent = event->getIf<sf::Event::JoystickDisconnected>()) {
                inputSystem.OnJoystickDisconnected(disconnectedEvent->joystickId);
            }
        }

        sf::Time time = clock.getElapsedTime();
        float timeNow = time.asSeconds();
        EHTime::SetDeltaTime(timeNow - previousTime);
        previousTime = timeNow;
        accumulator += EHTime::GetDeltaTime();
        while (accumulator >= EHTime::GetFixedDeltaTime())
        {
            accumulator -= EHTime::GetFixedDeltaTime();
            instance->TickGame(EHTime::FrameTime);
        }
        instance->DisplayGame(window);
    }
}
