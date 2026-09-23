#include "EHGameModeFighting.h"
#include <iostream>

#include "character/EHCharacter.h"
#include "character/EHCharacterMovementComponent.h"
#include "character/EHPaletteComponent.h"
#include "controller/EHPlayerController.h"
#include "core/EHGameInstance.h"
#include "datatable/EHCharacterTableRow.h"

FGameMatchSettings EHGameModeFighting::MatchSettings = FGameMatchSettings();

void EHGameModeFighting::InitializeGameMode() {
    EHGameMode::InitializeGameMode();
    if (!MatchSettings.IsValid()) MatchSettings = defaultMatchSettings;

    CreateActor(FName("camera"), FVector(0, 0));
    if (MatchSettings.playerSettings.size() < 2) {
        std::cerr << "Invalid size for Player Settings" << std::endl;
        return;
    }
    EHDataTableManager* dataTableManager = EHGameInstance::GetInstance()->GetDataTableManager();
    int i = 0;
    for (const auto& playerSettings : MatchSettings.playerSettings) {
        auto* controller = dynamic_cast<EHController*>(CreateActor(playerSettings.controllerType));
        auto* playerController = dynamic_cast<EHPlayerController*>(controller);
        if (playerController) playerController->SetInputDeviceId(playerSettings.inputDeviceId);
        AddController(controller);
        EHCharacterTableRow characterData;
        if (!dataTableManager->GetCharacterDataById(playerSettings.characterId, characterData)) {
            std::cout << "InitializeGameMode() - Failed to find Character Data with id: " << playerSettings.characterId.GetKey() << std::endl;
        }
        auto* character = dynamic_cast<EHCharacter*>(CreateActor(characterData.GetAssetId()));
        character->AssignController(controller);
        character->SetPosition(FVector(3.f * (i % 2 == 0 ? -1.f : 1.f), 0));
        EHPaletteComponent* palette = character->GetPaletteComponent();
        palette->ApplyColorPalette(playerSettings.characterId, playerSettings.colorSelection);
        EHCharacterMovementComponent* movement = dynamic_cast<EHCharacterMovementComponent*>(character->GetActorComponent(FName("movement")));
        if (movement) movement->SetIsFacingLeft(i % 2 == 0);
        i++;
    }
}

void EHGameModeFighting::TickGameMode(float deltaTime) {
    EHGameMode::TickGameMode(deltaTime);
    for (EHController* controller : controllers) {
        controller->TickController(gameFrame);
    }
    gameFrame++;
}
