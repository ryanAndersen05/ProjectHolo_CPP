#include "EHFollowCamera.h"
#include "factory/EHActorComponentFactory.h"
#include <algorithm>
#include <cmath>

void EHCameraFollow::LateTick(float deltaTime) {
    float totalX = 0.f;
    float highestY = 0.f;
    std::size_t count = 0;
    for (const EHActor* target : targetActors) {
        if (!target->GetIsActive()) continue;
        const FVector position = target->GetPosition();
        totalX += position.x;
        highestY = std::max(highestY, position.y);
        ++count;
    }
    if (count == 0) return;
    const FVector targetPosition(totalX / static_cast<float>(count), std::max(0.f, highestY - heightThreshold));
    // Exponential interpolation gives the same response across different tick rates.
    const float blend = followSpeed > 0.f ? 1.f - std::exp(-followSpeed * deltaTime) : 1.f;
    SetPosition(FVector::Lerp(GetPosition(), targetPosition, blend));
}

void EHCameraFollow::AddTargetActor(EHActor* target) {
    if (!target || target == this || std::ranges::find(targetActors, target) != targetActors.end()) return;
    targetActors.push_back(target);
}

void EHCameraFollow::RemoveTargetActor(EHActor* target) {
    std::erase(targetActors, target);
}

void EHCameraFollow::SetHeightThreshold(float threshold) {
    heightThreshold = std::max(0.f, threshold);
}

void EHCameraFollow::SetFollowSpeed(float speed) {
    followSpeed = std::max(0.f, speed);
}

EHCamera* EHCameraFollow::GetMainCamera() const {
    return dynamic_cast<EHCamera*>(GetActorComponent(EHActorComponentFactory::CameraComponentId));
}
