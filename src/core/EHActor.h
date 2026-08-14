#pragma once
#include "library/EHLibrary.h"
#include "interface/ITickable.h"
#include "interface/ILateTickable.h"
#include <vector>

class EHActorComponent;

struct FComponentContainer {
public:
    FName componentId;
    EHActorComponent* component;

    FComponentContainer(const FName& componentId, EHActorComponent* component) : componentId(componentId), component(component) {}
};

class EHActor
{
private:
    bool isActive;
    FVector position;
    float rotation;
    FVector scale;
    float timeScale;
    int actorId;

    EHActor* owner;

    std::vector<FComponentContainer> components;
    std::vector<ITickable*> tickables;
    std::vector<ILateTickable*> lateTickables;

protected:
    void AddComponent(const FName& componentId, EHActorComponent* component);

public:
    EHActor() : isActive(false), position(FVector::Zero), rotation(0.f), scale(FVector::Zero), timeScale(1.f), actorId(0), owner(nullptr) {}
    virtual ~EHActor();

    virtual void InitializeActor(int id);

    void TickActor(float deltaTime);

    void SetIsActive(const bool active) {this->isActive = active;}
    void SetPosition(const FVector& pos) { this->position = pos; }
    void SetRotation(const float rot) {this->rotation = rot; }
    void SetScale(const FVector& scl) {this->scale = scl; }
    void SetOwner(EHActor* own) { this->owner = own; }
    void SetTimeScale(const float timeScl) { this->timeScale = timeScl; }

    bool GetIsActive() const { return isActive; }
    FVector GetPosition() const { return position; }
    float GetRotation() const { return rotation; }
    FVector GetScale() const { return scale; }
    float GetActorTimeScale() const { return timeScale; }
    bool GetIsTickable() const { return !tickables.empty(); }
    bool GetIsLateTickable() const { return !lateTickables.empty(); }

    EHActor* GetOwner() const { return owner; }
    EHActorComponent* GetActorComponent(const FName& componentId) const;
};