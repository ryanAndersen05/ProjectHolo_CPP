#include <SFML/Graphics.hpp>
#include "library/EHGameData.h"
#include <iostream>
#include "core/EHGameInstance.h"
#include "core/EHLevel.h"
#include "core/EHTime.h"
#include "library/EHGameSettings.h"

int main()
{
    float accumulator = 0.f;
    float previousTime = 0.f;

    sf::Clock clock;
    sf::RenderWindow window(sf::VideoMode({ EHUserSettings::ScreenWidth, EHUserSettings::ScreenHeight }), "Oshi-Oshi Punch!");
    auto* instance = new EHGameInstance();
    EHGameSettings settings;
    if (!instance->LoadAsset<EHGameSettings>(FName("game_settings"), settings)) {
        std::cout << "Failed to load game_settings" << std::endl;
        return -1;
    }
    EHLevel level;
    if (!instance->LoadAsset<EHLevel>(settings.initialLevel, level)) {
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
