#include <SFML/Graphics.hpp>
#include "core/EHActor.h"
#include "library/EHJsonManager.h"
#include "sprite/EHSpriteData.h"
#include "library/EHGameData.h"
#include "sprite/EHSpriteComponent.h"
#include <iostream>

#include "../cmake-build-debug/_deps/sfml-src/src/SFML/Window/InputImpl.hpp"
#include "character/EHGura.h"
#include "core/EHGameInstance.h"

int main()
{
    float tickRate = 1.f / 60.f;
    float accumulator = 0.f;
    float previousTime = 0.f;

    sf::Clock clock;
    sf::RenderWindow window(sf::VideoMode({ EHGameSettings::ScreenWidth, EHGameSettings::ScreenHeight }), "Oshi-Oshi Punch!");
    std::cout << std::filesystem::current_path() << std::endl;
    EHGameInstance* instance = new EHGameInstance();
    instance->InitializeGame();

    EHGura guraActor = EHGura();
    EHSpriteComponent* spriteComponent = dynamic_cast<EHSpriteComponent *>(guraActor.GetActorComponent(FName("Sprite")));
    EHAnimatorComponent* animator = dynamic_cast<EHAnimatorComponent *>(guraActor.GetActorComponent(FName("Animator")));
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
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::S)) {
            animator->PlayAnimation(FName("gura_idle"));
        }
        else if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::A)) {
            animator->PlayAnimation(FName("gura_walkf"));
        }
        else if (sf::Keyboard::isKeyPressed(sf::Keyboard::Key::D)) {
            animator->PlayAnimation(FName("gura_walkb"));
        }
        window.clear();
        FSpriteDrawData drawData = spriteComponent->GetDrawData();
        FVectorInt position = drawData.spriteData.point;
        FVectorInt size = drawData.spriteData.size;
        sf::Sprite sprite = sf::Sprite(*drawData.texture, sf::IntRect({position.x, position.y}, {size.x, size.y}));
        window.draw(sprite);
        window.display();
    }
}
