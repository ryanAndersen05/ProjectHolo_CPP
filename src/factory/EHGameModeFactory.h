#pragma once
#include "core/EHGameMode.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

class EHGameModeFactory {
private:
    const static FName DefaultGameMode;
    const static FName FightingGameMode;
    const static FName ReplayGameMode;
    const static FName TrainingGameMode;

public:
    static EHGameMode* CreateGameMode(const FName& gameModeType, const json& data);
};

