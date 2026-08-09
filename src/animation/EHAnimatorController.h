#pragma once
#include <string>
#include <vector>
#include "library/EHLibrary.h"
#include <nlohmann/json.hpp>
#include "EHAnimationClip.h"


struct FParameter {
public:
    FName name;
};

struct FAnimatorController {
private:
    std::vector<FParameter> parameters;
    std::vector<std::string> clips;
    std::unordered_map<FName, FAnimationClip> animationMap;

public:
    bool GetAnimationClip(const FName& animName, FAnimationClip& outAnimClip) const;

    friend void to_json(nlohmann::json& j, const FAnimatorController& c);
    friend void from_json(const nlohmann::json& j, FAnimatorController& c);
};
