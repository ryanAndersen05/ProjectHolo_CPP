#pragma once
#include "core/EHActor.h"
#include "EHCamera.h"

// Follow after physics so the camera uses this frame's resolved target positions.
class EHCameraFollow : public EHActor, public ILateTickable {
private:
    std::vector<EHActor*> targetActors;
    float heightThreshold = 5.f;
    float followSpeed = 10.f;

public:
    void LateTick(float deltaTime) override;
    void AddTargetActor(EHActor* target);
    void RemoveTargetActor(EHActor* target);
    void SetHeightThreshold(float threshold);
    [[nodiscard]] float GetHeightThreshold() const { return heightThreshold; }
    // Higher values follow faster; zero disables smoothing.
    void SetFollowSpeed(float speed);
    [[nodiscard]] float GetFollowSpeed() const { return followSpeed; }
    [[nodiscard]] EHCamera* GetMainCamera() const;
};
