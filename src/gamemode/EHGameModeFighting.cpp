#include "EHGameModeFighting.h"

#include <iostream>

FGameMatchSettings EHGameModeFighting::MatchSettings = FGameMatchSettings();

void EHGameModeFighting::InitializeGameMode() {
    EHGameMode::InitializeGameMode();

    if (!MatchSettings.IsValid()) MatchSettings = defaultMatchSettings;

    CreateActor(FName("camera"), FVector(0, 0));
    if (MatchSettings.playerSettings.size() < 2) {
        std::cerr << "Invalid size for Player Settings" << std::endl;
        return;
    }
    CreateActor(MatchSettings.playerSettings[0].characterId, FVector(-1.5f, 0.f));
    CreateActor(MatchSettings.playerSettings[1].characterId, FVector(1.5f, 0));
}
