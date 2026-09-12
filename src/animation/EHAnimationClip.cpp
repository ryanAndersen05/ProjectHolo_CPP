#include "EHAnimationClip.h"

void to_json(nlohmann::json& j, const FAnimationClip& clip) {
    j = {{"clipName", clip.clipName}};
}

void from_json(const nlohmann::json& j, FAnimationClip& clip) {
    j.at("clipName").get_to(clip.clipName);
}

