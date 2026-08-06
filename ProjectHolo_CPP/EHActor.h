#pragma once
#include "SFML/Graphics.hpp"
#include "EHLibrary.h"
#include "ITickable.h"
#include "ILateTickable.h"
#include <vector>
#include <concepts>

class EHActorComponent;

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

    std::vector<EHActorComponent*> components;
    std::vector<ITickable*> tickables;
    std::vector<ILateTickable*> lateTickables;

protected:
    EHActorComponent* AddComponent(EHActorComponent* component);

public:
    EHActor() : isActive(false), position(FVector::Zero), rotation(0.f), scale(FVector::Zero), timeScale(1.f), actorId(0), owner(nullptr) {}
    ~EHActor();

    virtual void InitializeActor(int id);

    void TickActor(float deltaTime);

    void SetIsActive(const bool isActive);
    void SetPosition(const FVector& position);
    void SetRotation(const float rotation);
    void setScale(const FVector& scale);
    void SetOwner(const EHActor* owner);

    bool GetIsActive() const { return isActive; }
    FVector GetPosition() const { return position; }
    float GetRotation() const { return rotation; }
    FVector GetScale() const { return scale; }
    float GetActorTimeScale() const { return timeScale; }
    bool GetIsTickable() const { return tickables.size() > 0; }
    bool GetIsLateTickable() const { return lateTickables.size() > 0; }

    EHActor* GetOwner() const { return owner; }
};