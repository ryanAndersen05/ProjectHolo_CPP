#include "EHFollowCamera.h"
#include "factory/EHActorComponentFactory.h"
#include <algorithm>

void EHCameraFollow::LateTick(float) {
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
    SetPosition(FVector(totalX / static_cast<float>(count), std::max(0.f, highestY - heightThreshold)));
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

EHCamera* EHCameraFollow::GetMainCamera() const {
    return dynamic_cast<EHCamera*>(GetActorComponent(EHActorComponentFactory::CameraComponentId));
}
