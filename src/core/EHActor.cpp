#include "EHActor.h"
#include "EHActorComponent.h"

void EHActor::InitializeActor(int id)
{
    this->actorId = id;
}

EHActor::~EHActor()
{
    for (const auto & container : components)
    {
        delete container.component;
    }
}

void EHActor::TickActor(float deltaTime)
{
    float scaleTime = timeScale * deltaTime;
    for (ITickable* tickable : tickables)
    {
        tickable->Tick(scaleTime);
    }
}


void EHActor::AddComponent(const FName& componentId, EHActorComponent* component)
{
    components.emplace_back(componentId, component);
    component->InitializeComponent(this);
    auto* tickableComponent = dynamic_cast<ITickable*>(component);
    auto* lateTickableComponent = dynamic_cast<ILateTickable*>(component);

    if (tickableComponent)
    {
        tickables.push_back(tickableComponent);
    }
    if (lateTickableComponent)
    {
        lateTickables.push_back(lateTickableComponent);
    }
}

