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

void EHActor::SetIsActive(const bool active) {
    if (isActive == active) return;

    isActive = active;
    OnActorActive.Invoke(isActive, this);
}

void EHActor::TickActor(float deltaTime) const {
    float scaleTime = timeScale * deltaTime;
    for (ITickable* tickable : tickables)
    {
        tickable->Tick(scaleTime);
    }
}

void EHActor::LateTickActor(float deltaTime) const {
    float scaleTime = timeScale * deltaTime;
    for (ILateTickable* lateTickable : lateTickables) {
        lateTickable->LateTick(scaleTime);
    }
}


void EHActor::AddComponent(const FName& componentId, EHActorComponent* component)
{
    components.emplace_back(componentId, component);
    auto* tickableComponent = dynamic_cast<ITickable*>(component);
    auto* lateTickableComponent = dynamic_cast<ILateTickable*>(component);
    auto* displayableComponent = dynamic_cast<IDisplayable*>(component);

    if (tickableComponent)
    {
        tickables.push_back(tickableComponent);
    }
    if (lateTickableComponent)
    {
        lateTickables.push_back(lateTickableComponent);
    }
    if (displayableComponent) {
        displayables.push_back(displayableComponent);
    }
    component->InitializeComponent(this);
}

EHActorComponent* EHActor::GetActorComponent(const FName& componentId) const {
    for (const auto& container : components) {
        if (container.componentId == componentId) return container.component;
    }
    return nullptr;
}

void EHActor::DisplayActor(std::vector<FSpriteDisplayData> &displayData) const {
    for (const auto& displayable : displayables) {
        displayData.push_back(displayable->GetSpriteDrawData());
    }
}
