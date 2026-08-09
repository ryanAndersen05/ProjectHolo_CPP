#include "EHAnimatorComponent.h"
#include "library/EHJsonManager.h"


void EHAnimatorComponent::Tick(float deltaTime)
{
    time += deltaTime;
    if (time >= timeToNextFrame)
    {
        timeToNextFrame += 0.1f;
    }
}

void EHAnimatorComponent::InitializeAnimatorController(const std::string& controllerPath) {
    if (!EHJsonManager::Deserialize<FAnimatorController>(controllerPath, controller)) {
        std::cout << "Failed to load AnimatorController" << std::endl;
    }
}

// void EHAnimatorComponent::SetAnimation(const FName& animName) {
// }