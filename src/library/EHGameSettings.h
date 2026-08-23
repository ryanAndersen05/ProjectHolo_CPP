#pragma once
#include <string>
#include "core/EHGameInstance.h"
#include "nlohmann/json.hpp"

class EHGameSettings {
public:
    FName initialLevel;
    EHGameSettings() : initialLevel(FName("")) { }
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHGameSettings, initialLevel)
};