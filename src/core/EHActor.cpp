#include "EHActor.h"
#include "EHActorComponent.h"
#include "factory/EHActorComponentFactory.h"

void EHActor::InitializeActor(const json& componentJson)
{
    if (auto* tickable = dynamic_cast<ITickable*>(this)) tickables.push_back(tickable);
    if (auto* lateTickable = dynamic_cast<ILateTickable*>(this)) lateTickables.push_back(lateTickable);

    for (auto& component : componentJson) {
        FName componentType = component.at("componentType").get<FName>();
        FName componentName = component.at("componentName").get<FName>();
        json componentData = component.at("data");
        EHActorComponent* actorComponent = EHActorComponentFactory::CreateActorComponent(componentType, componentData);
        AddComponent(componentName, actorComponent);
    }
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

void EHActor::LateTickActor(float deltaTime) {
    float scaleTime = timeScale * deltaTime;
    if (auto* lateTickableActor = dynamic_cast<ILateTickable*>(this)) lateTickableActor->LateTick(scaleTime);
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

void EHActor::DisplayActor(FRenderQueue& displayData, const FRenderContext& context) const {
    for (const auto& displayable : displayables) {
        displayable->CollectDrawCommands(displayData, context);
    }
}
