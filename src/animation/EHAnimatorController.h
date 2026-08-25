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

struct FParameterValue {
public:
    union {
        float fValue;
        int iValue;
        bool bValue;
    };
};

struct FCondition {
public:
    FName parameter;
    EConditionType type;
    FParameterValue value;

    FCondition() : parameter(FName()), type(EConditionType::Equal), value(FParameterValue()) {}
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FCondition, parameter, type, value)

struct FTransition {
public:
    FName stateId;
    std::vector<FCondition> conditions;
    FTransition() : stateId(FName()) {}
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FTransition, stateId, conditions)

struct FParameter {
public:
    FName name;
    EParameterType type;
    FParameter() : name(FName()), type(EParameterType::Bool) {}
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FParameter, name, type)

struct FState {
public:
    FName stateName;
    std::vector<FTransition> transitions;
    FState() = default;
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FState, stateName, transitions)

struct FAnimatorController {
private:
    FName spriteMetaPath;
    std::vector<FParameter> parameters;
    std::vector<FName> clips;
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
