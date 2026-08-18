#include <SFML/Graphics.hpp>
#include "library/EHGameData.h"
#include <iostream>
#include "core/EHGameInstance.h"
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
    if (!EHJsonManager::Deserialize<EHGameSettings>("assets/GameSettings.json", settings)) {

    }
    instance->InitializeGame(FWorldSettings());

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
        }
        window.clear();
        window.display();
    }
}
