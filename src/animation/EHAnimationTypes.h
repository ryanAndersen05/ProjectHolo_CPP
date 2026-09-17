#pragma once
#include "library/EHLibrary.h"

enum class EParameterType {
    None =      0,
    Bool =      1,
    Int =       2,
    Float =     3,
    Trigger =   4,
};

struct FParameterValue {
public:
    union {
        float fValue;
        int iValue;
        bool bValue;
    };
};

struct FParameter {
public:
    FName name;
    EParameterType type;
    FParameter() : name(FName()), type(EParameterType::Bool) {}
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FParameter, name, type)
