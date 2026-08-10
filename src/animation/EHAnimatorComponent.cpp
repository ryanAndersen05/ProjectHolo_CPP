#include "EHAnimatorComponent.h"

#include "core/EHGameInstance.h"
#include "library/EHJsonManager.h"
#include "sprite/EHSpriteManager.h"


void EHAnimatorComponent::Tick(float deltaTime)
{
    controller.TickController(deltaTime);
}

void EHAnimatorComponent::InitializeAnimatorController(const std::string& controllerPath) {
    if (!EHJsonManager::Deserialize<FAnimatorController>(controllerPath, controller)) {
        std::cout << "Failed to load AnimatorController" << std::endl;
    }
    EHSpriteManager* spriteManager = EHGameInstance::GetInstance()->GetSpriteManager();
    spriteManager->LoadSpriteMetaData(controller.GetSpriteMetaPath());
    controller.InitializeAnimationClips(GetActor(), controllerPath);
    PlayAnimation(controller.GetStartClip());
}

void EHAnimatorComponent::PlayAnimation(const FName& animName) {
    controller.SetAnimationClip(animName);
}