#pragma once
#include "SFML/Graphics.hpp"
#include "EHLibrary.h"
#include <vector>
#include <concepts>

class EHActorComponent;
class EHAnimatorComponent;

class EHActor
{
private:
    bool isActive;
    FVector position;
    float rotation;
    FVector scale;
    float timeScale;

    EHActor* owner;
    std::vector<EHActorComponent*> components;

protected:
    EHAnimatorComponent* animator;

protected:
    EHActorComponent* AddComponent(EHActorComponent* component);

public:
    EHActor();
    ~EHActor();
    void InitializeActor(int id);
    void TickActor(float deltaTime);
    void DisplayActor(sf::RenderWindow& window);

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

    EHActor* GetOwner() const { return owner; }
    EHAnimatorComponent* GetAnimator() const { return animator; }

};