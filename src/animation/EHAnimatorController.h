#pragma once

#include <string>
#include <vector>
#include <nlohmann/json.hpp>

#include "EHAnimationClip.h"
#include "core/EHActor.h"
#include "library/EHLibrary.h"

enum EConditionType {
    Equal,
    NotEqual,
    GreaterThan,
    LessThan,
};

enum EParameterType {
    Bool,
    Float,
    Int,
    Trigger,
};

struct FCondition {
public:
    FName parameter;
    EConditionType type;
    float value;
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FCondition, parameter, type, value)

struct FTransition {
public:
    FName stateId;
    std::vector<FCondition> conditions;
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FTransition, stateId, conditions)

struct FParameter {
public:
    FName name;
    EParameterType type;
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FParameter, name, type)

struct FParameterValue {
public:
    union {
        float fValue;
        int iValue;
        bool bValue;
    };


};

struct FAnimatorController {
private:
    std::string spriteMetaPath;
    std::vector<FParameter> parameters;
    std::vector<std::string> clips;
    std::unordered_map<FName, FAnimationClip> animationMap;
    std::unordered_map<FName, FParameterValue> parameterValues;
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
