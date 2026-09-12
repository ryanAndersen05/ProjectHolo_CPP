#pragma once
#include "library/EHLibrary.h"
#include "nlohmann/json.hpp"
#include "animation/EHAnimationTypes.h"

using json = nlohmann::json;

enum EConditionType {
    Equal,
    NotEqual,
    GreaterThan,
    LessThan,
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

struct FAnimationClip
{
public:
    FName clipName;
    std::vector<FTransition> transitions;

    FAnimationClip() : clipName(FName("")) {};

    friend void to_json(json& j, const FAnimationClip& clip);
    friend void from_json(const json& j, FAnimationClip& clip);
};