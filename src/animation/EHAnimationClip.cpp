#include "EHAnimationClip.h"

float FAnimationClip::GetMaxTime() const {
    if (nodes.empty()) return 0.f;
    return nodes[nodes.size() - 1].time;
}

void to_json(nlohmann::json& j, const FAnimationNode& node) {
    j = {{"spriteId", node.spriteId}, {"time", node.time}};
}

void from_json(const nlohmann::json& j, FAnimationNode& node) {
    j.at("spriteId").get_to(node.spriteId);
    j.at("time").get_to(node.time);
}

void to_json(nlohmann::json& j, const FAnimationClip& clip) {
    j = {{"clipName", clip.clipName}, {"isLooping", clip.isLooping}, {"nodes", clip.nodes}};
}

void from_json(const nlohmann::json& j, FAnimationClip& clip) {
    j.at("clipName").get_to(clip.clipName);
    j.at("isLooping").get_to(clip.isLooping);
    for (const auto& node : j.at("nodes")) {
        FAnimationNode nodeData = node.get<FAnimationNode>();
        clip.nodes.push_back(nodeData);
    }
}

