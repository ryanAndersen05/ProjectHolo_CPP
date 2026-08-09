#include "EHAnimatorController.h"
#include "EHAnimationClip.h"


bool FAnimatorController::GetAnimationClip(const FName &animName, FAnimationClip &outAnimClip) const{
    if (!animationMap.contains(animName)) {
        return false;
    }

    outAnimClip = animationMap.at(animName);
    return true;
}

void to_json(nlohmann::json &j, const FAnimatorController &controller) {
    j = {{"clips", controller.clips}};
}

void from_json(const nlohmann::json &j, FAnimatorController &controller) {
    for (const auto& clip : j.at("clips")) {
        std::string clipData = clip.get<std::string>();
        controller.clips.push_back(clipData);
    }
}