#include "EHActor.h"
#include "EHActorComponent.h"
#include "EHAnimatorComponent.h"

void EHActor::InitializeActor(int id)
{
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
    float scaleTime = timeScale * deltaTime;
    for (ITickable* tickable : tickables)
    {
        tickable->Tick(scaleTime);
    }
}


EHActorComponent* EHActor::AddComponent(EHActorComponent* component)
{
    components.push_back(component);
    component->InitializeComponent(this);
    ITickable* tickableComponent = dynamic_cast<ITickable*>(component);
    ILateTickable* lateTickableComponent = dynamic_cast<ILateTickable*>(component);

    if (tickableComponent)
    {
        tickables.push_back(tickableComponent);
    }
    if (lateTickableComponent)
    {
        lateTickables.push_back(lateTickableComponent);
    }
    return component;
}