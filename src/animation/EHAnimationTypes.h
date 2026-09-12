#pragma once

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

struct FParameter {
public:
    FName name;
    EParameterType type;
    FParameter() : name(FName()), type(EParameterType::Bool) {}
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FParameter, name, type)