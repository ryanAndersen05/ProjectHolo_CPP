#pragma once
#include "EHActor.h"
#include "EHController.h"
#include "nlohmann/json.hpp"
class EHGameMode {
private:
    std::vector<EHActor*> activeActors;
    std::vector<EHActor*> allActors;
    std::vector<EHActor*> pendingAddActors;
    std::vector<EHActor*> pendingRemoveActors;

    std::vector<EHController*> controllers;

private:
    void AddController(const FName& controllerId);

public:
    EHGameMode();
    virtual ~EHGameMode();
    virtual void TickGameMode();
    EHController* GetControllerAtIndex(int index);

    EHActor* CreateActor(const FName& actorId, const FVector& position = FVector::Zero, float rotation = 0.f);
    void DestroyActor(const EHActor* actor);
};