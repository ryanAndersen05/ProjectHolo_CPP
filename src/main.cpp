#include <SFML/Graphics.hpp>
#include "core/EHActor.h"
#include "library/EHJsonManager.h"
#include "sprite/EHSpriteData.h"
#include <iostream>

int main()
{
    float tickRate = 1.f / 60.f;
    float accumulator = 0.f;
    float previousTime = 0.f;

    sf::Clock clock;
    sf::RenderWindow window(sf::VideoMode({ 640, 360 }), "Oshi-Oshi Punch!");
    FSpriteMetaData guraSpriteData;
    EHJsonManager::Deserialize<FSpriteMetaData>("assets/sprites/Gura/GuraAtlas.json", guraSpriteData);

    std::cout << std::filesystem::current_path() << std::endl;

    EHActor guraActor = EHActor();

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
        float deltaTime = timeNow - previousTime;
        previousTime = timeNow;
        accumulator += deltaTime;

        while (accumulator >= tickRate)
        {
            guraActor.TickActor(tickRate);
            accumulator -= tickRate;
        }

        window.clear();
        window.display();
    }
}
