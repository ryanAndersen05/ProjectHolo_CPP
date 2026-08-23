#pragma once
#include "EHGameInstance.h"

class EHLevel {
public:
    FWorldSettings worldSettings;
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(EHLevel, worldSettings)
