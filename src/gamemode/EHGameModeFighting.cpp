#include "EHGameModeFighting.h"

#include <iostream>

#include "character/EHPaletteComponent.h"

FGameMatchSettings EHGameModeFighting::MatchSettings = FGameMatchSettings();

void EHGameModeFighting::InitializeGameMode() {
    EHGameMode::InitializeGameMode();

    if (!MatchSettings.IsValid()) MatchSettings = defaultMatchSettings;

    CreateActor(FName("camera"), FVector(0, 0));
    if (MatchSettings.playerSettings.size() < 2) {
        std::cerr << "Invalid size for Player Settings" << std::endl;
        return;
    }
    FPlayerSettings& kiaraSettings = MatchSettings.playerSettings[0];
    EHActor* kiara = CreateActor(MatchSettings.playerSettings[0].characterId, FVector(-1.5f, 0.f));
    CreateActor(MatchSettings.playerSettings[1].characterId, FVector(1.5f, 0));
    EHPaletteComponent* kiaraPalette = dynamic_cast<EHPaletteComponent*>(kiara->GetActorComponent(FName("palette")));
    kiaraPalette->ApplyColorPalette(kiaraSettings.characterId, kiaraSettings.colorSelection);
}
