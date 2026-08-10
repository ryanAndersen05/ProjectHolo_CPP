#include "EHAnimatorController.h"
#include "core/EHGameInstance.h"
#include "library/EHJsonManager.h"
#include "sprite/EHSpriteComponent.h"


FAnimatorController::FAnimatorController() : startClip(FName("")) {
    spriteMetaPath = "";
    parameters = std::vector<FParameter>();
    clips = std::vector<std::string>();
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
                EHSpriteComponent* spriteComponent = dynamic_cast<EHSpriteComponent*>(actor->GetActorComponent(FName("Sprite")));
                EHSpriteManager* spriteManager = EHGameInstance::GetInstance()->GetSpriteManager();
                FSpriteDrawData drawData;
                if (spriteManager->GetSprteDrawData(node.spriteId, drawData)) {
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

void FAnimatorController::InitializeAnimationClips(EHActor* actr, const std::string& controllerPath) {
    this->actor = actr;
    std::filesystem::path animationPath(controllerPath);
    animationPath = animationPath.parent_path(); // directory
    for (const std::string& clipName : clips) {
        std::filesystem::path clipPath(clipName + ".json");
        std::filesystem::path fullClipPath = animationPath / clipPath;
        FAnimationClip clip;
        if (EHJsonManager::Deserialize(fullClipPath.string(), clip)) {
            animationMap.insert({clip.clipName, clip});
        }
    }
}

void to_json(nlohmann::json &j, const FAnimatorController &controller) {
    j = {{"spriteMetaPath", controller.spriteMetaPath}, {"startClip", controller.startClip}, {"clips", controller.clips}};
}

void from_json(const nlohmann::json &j, FAnimatorController &controller) {
    j.at("spriteMetaPath").get_to(controller.spriteMetaPath);
    j.at("startClip").get_to(controller.startClip);

    for (const auto& clip : j.at("clips")) {
        std::string clipData = clip.get<std::string>();
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
