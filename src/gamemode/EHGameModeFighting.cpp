#include "EHGameModeFighting.h"
#include <iostream>

#include "character/EHCharacter.h"
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
    EHDataTableManager* dataTableManager = EHGameInstance::GetInstance()->GetDataTableManager();
    for (const auto& playerSettings : MatchSettings.playerSettings) {
        EHCharacterTableRow characterData;
        if (!dataTableManager->GetCharacterDataById(playerSettings.characterId, characterData)) {
            std::cout << "InitializeGameMode() - Failed to find Character Data with id: " << playerSettings.characterId.GetKey() << std::endl;
        }
        auto* character = dynamic_cast<EHCharacter*>(CreateActor(characterData.GetAssetId()));
        EHPaletteComponent* palette = character->GetPaletteComponent();
        palette->ApplyColorPalette(playerSettings.characterId, playerSettings.colorSelection);
    }
}

void EHGameModeFighting::OnInputPressed(sf::Keyboard::Key, bool) {
    // if (!isPressed) return;
    //
    // if (keyPressed == sf::Keyboard::Key::A) {
    //     colorPaletteIndex--;
    // }
    // else if (keyPressed == sf::Keyboard::Key::D) {
    //     colorPaletteIndex++;
    // }
    // else return;
    //
    // FName kiaraName("kiara");
    // EHGameInstance* gameInstance = EHGameInstance::GetInstance();
    // EHDataTableManager* dataTableManager = gameInstance->GetDataTableManager();
    // EHCharacterTableRow tableRow;
    // if (!dataTableManager->GetCharacterDataById(kiaraName, tableRow)) {
    //     return;
    // }
    // int size = static_cast<int>(tableRow.GetColorPalettes().size());
    // colorPaletteIndex = EHMath::SafeMod(colorPaletteIndex, size);
    //
    // EHPaletteComponent* kiaraPalette = dynamic_cast<EHPaletteComponent*>(kiara->GetActorComponent(FName("palette")));
    // kiaraPalette->ApplyColorPalette(kiaraName, colorPaletteIndex);;
}
