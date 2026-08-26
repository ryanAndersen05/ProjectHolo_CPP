#include "EHFollowCamera.h"
#include <iostream>

void EHCameraFollow::InitializeActor(int id) {
    EHActor::InitializeActor(id);
    cameraComponent = dynamic_cast<EHCamera*>(GetActorComponent(FName("camera")));
}

void EHCameraFollow::AddTargetActor(EHActor *target) {
    if (std::ranges::find(targetActors, target) != targetActors.end()) {
        std::cout << "Target was already added." << std::endl;
        return;
    }
}

void EHCameraFollow::RemoveTargetActor(EHActor *target) {
    std::erase(targetActors, target);
}
