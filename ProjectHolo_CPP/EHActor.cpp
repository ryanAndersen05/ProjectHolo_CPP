#include "EHActor.h"
#include "EHActorComponent.h"
#include "EHAnimatorComponent.h"

EHActor::EHActor()
{
    timeScale = 1.f;
    animator = new EHAnimatorComponent("assets/Sprites/Gura/GuraIdle-Sheet.png", 10);
    AddComponent(animator);
}

EHActor::~EHActor()
{
    for (int i = 0; i < components.size(); ++i)
    {
        delete components[i];
    }
}

void EHActor::TickActor(float deltaTime)
{
    // for (EHActorComponent& component : components)
    // {

    // }
    float scaleTime = timeScale * deltaTime;
    animator->tick(scaleTime);
}

void EHActor::DisplayActor(sf::RenderWindow& window)
{
    animator->draw(window);
}


EHActorComponent* EHActor::AddComponent(EHActorComponent* component)
{
    components.push_back(component);
    component->InitializeComponent(this);
    return component;
}