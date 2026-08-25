#include "EHAnimatorComponent.h"
#include "core/EHGameInstance.h"
#include "library/EHJsonManager.h"
#include "sprite/EHSpriteManager.h"


void EHAnimatorComponent::Tick(float deltaTime)
{
    controller.TickController(deltaTime);
}

void EHAnimatorComponent::InitializeComponent(EHActor *actr) {
    EHActorComponent::InitializeComponent(actr);
    if (defaultControllerAsset.isValid()) InitializeAnimatorController(defaultControllerAsset);
}

void EHAnimatorComponent::InitializeAnimatorController(const FName& controllerAsset) {
    if (!EHGameInstance::LoadAsset<FAnimatorController>(controllerAsset, controller)) {
        std::cout << "Failed to load AnimatorController" << std::endl;
        return;
    }
    EHSpriteManager* spriteManager = EHGameInstance::GetInstance()->GetSpriteManager();
    spriteManager->LoadSpriteMetaData(controller.GetSpriteMetaPath());
    controller.InitializeAnimationClips(GetActor());
    PlayAnimation(controller.GetStartClip());
}

void EHAnimatorComponent::PlayAnimation(const FName& animName) {
    controller.SetAnimationClip(animName);
}

