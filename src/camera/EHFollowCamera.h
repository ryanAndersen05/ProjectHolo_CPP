#pragma once
#include "core/EHActor.h"
#include "EHCamera.h"

// Follow after physics so the camera uses this frame's resolved target positions.
class EHCameraFollow : public EHActor, public ILateTickable {
private:
    std::vector<EHActor*> targetActors;
    float heightThreshold = 5.f;

public:
    void LateTick(float deltaTime) override;
    void AddTargetActor(EHActor* target);
    void RemoveTargetActor(EHActor* target);
    void SetHeightThreshold(float threshold);
    [[nodiscard]] float GetHeightThreshold() const { return heightThreshold; }
    [[nodiscard]] EHCamera* GetMainCamera() const;
};