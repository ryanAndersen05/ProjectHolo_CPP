#pragma once
#include "EHActor.h"
#include "EHController.h"
#include "sprite/EHSpriteManager.h"

class EHGameMode {
private:
    std::vector<EHActor*> tickableActors;
    std::vector<EHActor*> lateTickableActors;
    std::vector<EHActor*> allActors; // This is the list that contains all actors currently spawned in the game regardless of their active status
    std::vector<EHActor*> displayableActors;

    std::vector<EHActor*> pendingAddActors;
    std::vector<EHActor*> pendingRemoveActors;

    std::vector<EHController*> controllers;

private:
    void AddController(const FName& controllerId);
    void OnActorActive(bool isActive, EHActor* actor);

protected:
    void TickActors(float deltaTime) const;
    void LateTickActors(float deltaTime) const;

public:
    EHGameMode();
    virtual ~EHGameMode();
    virtual void InitializeGameMode();
    virtual void TickGameMode(float deltaTime);

    void DisplayGameMode(std::vector<FSpriteDisplayData>& displayData) const;
    [[nodiscard]] EHController* GetControllerAtIndex(int index) const;

    EHActor* CreateActor(const FName& actorId, EHActor* owner, const FVector& position = FVector::Zero, float rotation = 0.f, const FVector& scale = FVector::Zero);
    EHActor* CreateActor(const FName& actorId, const FVector& position, float rotation = 0.f) {return CreateActor(actorId, nullptr, position, rotation);}
    EHActor* CreateActor(const FName& actorId) {return CreateActor(actorId, nullptr, FVector::Zero, 0.0f);}
    void DestroyActor(EHActor* actor);
};
