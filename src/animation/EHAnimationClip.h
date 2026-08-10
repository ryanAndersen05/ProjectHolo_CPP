#pragma once
#include "library/EHLibrary.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

struct FAnimationNode
{
public:
    FName spriteId;
    float time;
    FAnimationNode() : spriteId(FName("")), time(0.0) {}

    friend void to_json(json& j, const FAnimationNode& node);
    friend void from_json(const json& j, FAnimationNode& node);
};

struct FAnimationClip
{
public:
    FName clipName;
    bool isLooping;
    std::vector<FAnimationNode> nodes;

    FAnimationClip() : clipName(FName("")), isLooping(false) {};
    float GetMaxTime() const;

    friend void to_json(json& j, const FAnimationClip& clip);
    friend void from_json(const json& j, FAnimationClip& clip);
};