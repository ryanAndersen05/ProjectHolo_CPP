#pragma once
#include <nlohmann/json.hpp>
#include "EHAnimationClip.h"
#include "core/EHActor.h"
#include "library/EHLibrary.h"
#include "sol/sol.hpp"
#include "animation/EHAnimationTypes.h"

struct FAnimatorController {
private:
    sol::table stateMachineTable;
    FName spriteMetaPath;
    FName stateMachineAsset;
    std::unordered_map<FName, FAnimationClip> animationMap;
    std::unordered_map<FName, FParameterValue> parameterValues;
    int frame;
    FAnimationClip currentClip;
    EHActor* actor;
    FName startClip;

public:
    FAnimatorController();
    void TickController(float deltaTime);
    bool GetAnimationClip(const FName& animName, FAnimationClip& outAnimClip) const;
    const FName& GetStartClip() const { return startClip; }
    const FName& GetSpriteMetaPath() const { return spriteMetaPath; };
    void InitializeAnimationClips(EHActor* actr);
    void SetAnimationClip(const FName& animName);

    void SetBool(const FName&, bool);
    void SetFloat(const FName&, float);
    void SetInt(const FName&, int);
    void SetTrigger(const FName&);

    bool GetBool(const FName&);
    float GetFloat(const FName&);
    int GetInt(const FName&);
    void ResetTrigger(const FName&);

    friend void to_json(nlohmann::json& j, const FAnimatorController& c);
    friend void from_json(const nlohmann::json& j, FAnimatorController& c);
};
