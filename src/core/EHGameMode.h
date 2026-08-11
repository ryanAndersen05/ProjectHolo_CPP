#pragma once
#include "EHActor.h"
#include "EHController.h"

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
    void TickGameMode();
    EHController* GetControllerAtIndex(int index);

    void CreateActor(const FName& actorId);
    void DestroyActor(const EHActor* actor);
};