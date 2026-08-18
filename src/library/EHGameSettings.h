#pragma once
#include <string>
#include "nlohmann/json.hpp"

class EHGameSettings {
public:
    std::string initialLevel;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHGameSettings, initialLevel)
};