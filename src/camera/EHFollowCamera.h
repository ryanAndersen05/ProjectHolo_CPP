#pragma once
#include "core/EHActor.h"
#include "EHCamera.h"

class EHCameraFollow : public EHActor {
private:
    std::vector<EHActor*> targetActors;
    FRect targetBounds;
    EHCamera* cameraComponent;

public:

    void InitializeActor(int id) override;
    void AddTargetActor(EHActor* target);
    void RemoveTargetActor(EHActor* target);
    EHCamera* GetMainCamera() {return cameraComponent;};
};