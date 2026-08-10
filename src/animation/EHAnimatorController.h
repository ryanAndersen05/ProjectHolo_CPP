#pragma once

#include <string>
#include <vector>
#include <nlohmann/json.hpp>

#include "EHAnimationClip.h"
#include "core/EHActor.h"
#include "library/EHLibrary.h"

enum EParameterType {
    Bool,
    Float,
    Integer,
    Trigger,
};

struct FParameter {
public:
    FName name;
    EParameterType type;
};

struct FAnimatorController {
private:
    std::string spriteMetaPath;
    std::vector<FParameter> parameters;
    std::vector<std::string> clips;
    std::unordered_map<FName, FAnimationClip> animationMap;
    float time;
    FAnimationClip currentClip;
    EHActor* actor;
    FName startClip;

public:
    FAnimatorController();
    void TickController(float deltaTime);
    bool GetAnimationClip(const FName& animName, FAnimationClip& outAnimClip) const;
    const FName& GetStartClip() const { return startClip; }
    const std::string& GetSpriteMetaPath() const { return spriteMetaPath; };
    void InitializeAnimationClips(EHActor* actr, const std::string& controllerPath);
    void SetAnimationClip(const FName& animName);

    friend void to_json(nlohmann::json& j, const FAnimatorController& c);
    friend void from_json(const nlohmann::json& j, FAnimatorController& c);
};
