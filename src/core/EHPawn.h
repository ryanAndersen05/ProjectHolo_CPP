#pragma once
#include "EHActor.h"
#include "EHController.h"

class EHPawn : public EHActor {
private:
    EHController* owningController;
public:
    EHPawn() : EHActor(), owningController(nullptr) {}
    ~EHPawn() override;
    EHController* GetController() const { return owningController; }
    void AssignController(EHController* controller);
};
