#include "EHAnimatorComponent.h"
#include <iostream>
#include <string>


void EHAnimatorComponent::tick(float deltaTime)
{
    time += deltaTime;
    if (time >= timeToNextFrame)
    {
        timeToNextFrame += 0.1f;
        currentFrame = (currentFrame + 1) % totalFrames;
    }
}

void EHAnimatorComponent::draw(sf::RenderWindow& window)
{
    sf::Sprite sprite(texture, sf::IntRect({ 96 * currentFrame, 0 }, { 96, 96 }));
    window.draw(sprite);
}