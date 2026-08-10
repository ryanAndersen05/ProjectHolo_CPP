#pragma once
#include "core/EHActorComponent.h"
#include "SFML/Graphics.hpp"
#include "EHAnimatorController.h"

class EHAnimatorComponent : public EHActorComponent, public ITickable
{
private:
    float timeToNextFrame;
    int currentNodeIndex;
    FAnimatorController controller;

public:
    EHAnimatorComponent() : timeToNextFrame(0.f), currentNodeIndex(0) {};
    void Tick(float deltaTime) override;
    void InitializeAnimatorController(const std::string& controllerPath);

    void PlayAnimation(const FName& animName);
};