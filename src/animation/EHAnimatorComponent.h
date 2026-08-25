#pragma once
#include "core/EHActorComponent.h"
#include "EHAnimatorController.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

class EHAnimatorComponent : public EHActorComponent, public ITickable
{
private:
    FName defaultControllerAsset;
    float timeToNextFrame;
    int currentNodeIndex;
    FAnimatorController controller;

public:
    EHAnimatorComponent() : timeToNextFrame(0.f), currentNodeIndex(0) {};
    void InitializeComponent(EHActor *actr) override;
    void Tick(float deltaTime) override;
    void InitializeAnimatorController(const FName& controllerAsset);
    void PlayAnimation(const FName& animName);

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHAnimatorComponent, defaultControllerAsset);
};