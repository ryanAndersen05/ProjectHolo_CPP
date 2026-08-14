#pragma once
#include "core/EHActorComponent.h"
#include "EHAnimatorController.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

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

    friend void from_json(const json& j, EHAnimatorComponent& controller);
};