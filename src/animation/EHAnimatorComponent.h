#pragma once
#include "core/EHActorComponent.h"
#include "SFML/Graphics.hpp"
#include "animation/EHAnimatorController.h"

class EHAnimatorComponent : public EHActorComponent, public ITickable
{
private:
    float time;
    float timeToNextFrame;
    int currentNodeIndex;
    FAnimatorController controller;

public:
    EHAnimatorComponent() : time(0.f), timeToNextFrame(0.f), currentNodeIndex(0), controller(FAnimatorController() ){};
    void Tick(float deltaTime) override;
    void InitializeAnimatorController(const std::string& controllerPath);

    void SetAnimation(const FName& animName);
};