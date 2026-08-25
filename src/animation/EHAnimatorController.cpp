#include "EHAnimatorController.h"
#include "core/EHGameInstance.h"
#include "factory/EHActorComponentFactory.h"
#include "library/EHJsonManager.h"
#include "sprite/EHSpriteComponent.h"


FAnimatorController::FAnimatorController() : startClip(FName("")) {
    spriteMetaPath = FName("");
    parameters = std::vector<FParameter>();
    clips = std::vector<FName>();
    animationMap = std::unordered_map<FName, FAnimationClip>();
    time = 0.0f;
    currentClip = FAnimationClip();
    actor = nullptr;
}

void FAnimatorController::TickController(float deltaTime) {
    float previousTime = time;
    time += deltaTime;
    float adjustedTime = time;
    if (currentClip.isLooping) {
        float maxTime = currentClip.GetMaxTime();
        float adjustMent = static_cast<int>(time / maxTime) * maxTime;
        previousTime -= adjustMent;
        adjustedTime -= adjustMent;
    }

    for (int i = currentClip.nodes.size() - 1; i >= 0; i--) {
        FAnimationNode node = currentClip.nodes[i];
        if (adjustedTime >= node.time) {
            if (previousTime <= node.time) {
                EHSpriteComponent* spriteComponent = dynamic_cast<EHSpriteComponent*>(actor->GetActorComponent(EHActorComponentFactory::SpriteComponentId));
                EHSpriteManager* spriteManager = EHGameInstance::GetInstance()->GetSpriteManager();
                FSpriteDrawData drawData;
                if (spriteManager->GetSpriteDrawData(node.spriteId, drawData)) {
                    spriteComponent->SetDrawData(drawData);
                }
            }
            else return;
        }
    }
}

bool FAnimatorController::GetAnimationClip(const FName &animName, FAnimationClip &outAnimClip) const{
    if (!animationMap.contains(animName)) {
        return false;
    }
    outAnimClip = animationMap.at(animName);
    return true;
}

void FAnimatorController::InitializeAnimationClips(EHActor* actr) {
    this->actor = actr;

    for (const FName& clipName : clips) {
        FAnimationClip clip;
        if (EHGameInstance::LoadAsset<FAnimationClip>(clipName, clip)) {
            animationMap.insert({clip.clipName, clip});
        }
    }
}

void FAnimatorController::SetBool(const FName& id, bool value) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].bValue = value;
}

void FAnimatorController::SetInt(const FName& id, int value) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].iValue = value;
}

void FAnimatorController::SetFloat(const FName& id, float value) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].fValue = value;
}

void FAnimatorController::SetTrigger(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].bValue = true;
}

void FAnimatorController::ResetTrigger(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].bValue = false;
}

bool FAnimatorController::GetBool(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return false;
    }
    return parameterValues[id].bValue;
}

int FAnimatorController::GetInt(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return 0;
    }
    return parameterValues[id].iValue;
}

float FAnimatorController::GetFloat(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return 0.f;
    }

    return parameterValues[id].fValue;
}

void to_json(nlohmann::json &j, const FAnimatorController &controller) {
    j = {{"spriteMetaPath", controller.spriteMetaPath}, {"startClip", controller.startClip}, {"clips", controller.clips}};
}

void from_json(const nlohmann::json &j, FAnimatorController &controller) {
    j.at("spriteMetaPath").get_to(controller.spriteMetaPath);
    j.at("startClip").get_to(controller.startClip);

    for (const auto& clip : j.at("clips")) {
        FName clipData = clip.get<FName>();
        controller.clips.push_back(clipData);
    }
}

void FAnimatorController::SetAnimationClip(const FName& animName) {
    if (!animationMap.contains(animName)) {
        std::cout << "Failed to retrieve animation with key: " << animName.GetKey() << std::endl;
        return;
    }
    currentClip = animationMap.at(animName);
    time = 0;
}
