#pragma once
#include <string>
#include "SFML/Graphics.hpp"
#include "EHActorComponent.h"

class EHAnimatorComponent : public EHActorComponent
{
private:
    float time;
    float timeToNextFrame;
    int currentFrame;
    int totalFrames;
    sf::Texture texture;

public:
    EHAnimatorComponent(std::string path, int frames);
    void tick(float deltaTime);
    void draw(sf::RenderWindow& window);
};