#pragma once
#include "core/EHGameMode.h"
#include "library/EHlibrary.h"

class EHGameModeFactory {
private:
    // static constexpr unsigned long SplashScreenGameMode = FName::StringToHash("SplashScreenGameMode");
    // static constexpr unsigned long MainMenuGameMode = FName::StringToHash("SplashScreenGameMode");
    // static constexpr unsigned long CharacterSelectGameMode = FName::StringToHash("SplashScreenGameMode");
    // static constexpr unsigned long FightingGameMode = FName::StringToHash("SplashScreenGameMode");
    // static constexpr unsigned long TrainingGameMode = FName::StringToHash("SplashScreenGameMode");
    // static constexpr unsigned long NetworkedGameMode = FName::StringToHash("SplashScreenGameMode");
    // static constexpr unsigned long ReplayGameMode = FName::StringToHash("SplashScreenGameMode");

public:
    static EHGameMode* CreateGameMode(const FName* gameModeId);
};

