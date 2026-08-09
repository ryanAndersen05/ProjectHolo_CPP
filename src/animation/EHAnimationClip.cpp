#include "EHAnimationClip.h"


void to_json(nlohmann::json& j, const FAnimationNode& node) {
    j = {{"spriteId", node.spriteId}, {"time", node.time}};
}

void from_json(const nlohmann::json& j, FAnimationNode& node) {
    j.at("spriteId").get_to(node.spriteId);
    j.at("time").get_to(node.time);
}

void to_json(nlohmann::json& j, const FAnimationClip& clip) {
    j = {{"clipName", clip.clipName}, {"nodes", clip.nodes}};
}

void from_json(const nlohmann::json& j, FAnimationClip& clip) {
    j.at("clipName").get_to(clip.clipName);
    for (const auto& node : j.at("nodes")) {
        FAnimationNode nodeData = node.get<FAnimationNode>();
        clip.nodes.push_back(nodeData);
    }
}