#include "EHGameModeFighting.h"
#include <iostream>
#include "character/EHPaletteComponent.h"
#include "core/EHGameInstance.h"
#include "datatable/EHCharacterTableRow.h"
#include "input/EHInputSystem.h"

FGameMatchSettings EHGameModeFighting::MatchSettings = FGameMatchSettings();

void EHGameModeFighting::InitializeGameMode() {
    EHGameMode::InitializeGameMode();
    if (!MatchSettings.IsValid()) MatchSettings = defaultMatchSettings;

    EHInputSystem* inputSystem = EHInputSystem::GetInstance();
    inputSystem->OnKeyboardPressedEvent.AddListener(
        [this](sf::Keyboard::Key key, bool isPressed) {
            OnInputPressed(key, isPressed);
        });
    CreateActor(FName("camera"), FVector(0, 0));
    if (MatchSettings.playerSettings.size() < 2) {
        std::cerr << "Invalid size for Player Settings" << std::endl;
        return;
    }
    FPlayerSettings& kiaraSettings = MatchSettings.playerSettings[0];
    kiara = CreateActor(MatchSettings.playerSettings[0].characterId, FVector(-1.5f, 0.f));
    CreateActor(MatchSettings.playerSettings[1].characterId, FVector(1.5f, 0));
    EHPaletteComponent* kiaraPalette = dynamic_cast<EHPaletteComponent*>(kiara->GetActorComponent(FName("palette")));
    kiaraPalette->ApplyColorPalette(kiaraSettings.characterId, kiaraSettings.colorSelection);
}

void EHGameModeFighting::OnInputPressed(sf::Keyboard::Key keyPressed, bool isPressed) {
    if (!isPressed) return;

    if (keyPressed == sf::Keyboard::Key::A) {
        colorPaletteIndex--;
    }
    else if (keyPressed == sf::Keyboard::Key::D) {
        colorPaletteIndex++;
    }
    else return;

    FName kiaraName("kiara");
    EHGameInstance* gameInstance = EHGameInstance::GetInstance();
    EHDataTableManager* dataTableManager = gameInstance->GetDataTableManager();
    EHCharacterTableRow tableRow;
    if (!dataTableManager->GetCharacterDataById(kiaraName, tableRow)) {
        return;
    }
    int size = static_cast<int>(tableRow.GetColorPalettes().size());
    colorPaletteIndex = EHMath::SafeMod(colorPaletteIndex, size);

    EHPaletteComponent* kiaraPalette = dynamic_cast<EHPaletteComponent*>(kiara->GetActorComponent(FName("palette")));
    kiaraPalette->ApplyColorPalette(kiaraName, colorPaletteIndex);;
}
