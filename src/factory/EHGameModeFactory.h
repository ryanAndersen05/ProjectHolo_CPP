#pragma once
#include "core/EHGameMode.h"
#include "library/EHLibrary.h"

enum EGameModeType : std::uint8_t {
    Default,
    Fighting,
    Training,
    Networked,
    Replay
};

class EHGameModeFactory {
private:


public:
    static EHGameMode* CreateGameMode(const EGameModeType gameModeType);
};

