#include "EHGameModeFighting.h"
#include <iostream>

#include "character/EHCharacter.h"
#include "camera/EHFollowCamera.h"
#include "world/EHWorld.h"
#include "physics/EHPhysicsSystem.h"
#include "character/EHCharacterMovementComponent.h"
#include "character/EHPaletteComponent.h"
#include "controller/EHPlayerController.h"
#include "core/EHGameInstance.h"
#include "datatable/EHCharacterTableRow.h"

const FName EHGameModeFighting::WorldAssetId = FName("default_world");

FGameMatchSettings EHGameModeFighting::MatchSettings = FGameMatchSettings();

void EHGameModeFighting::InitializeGameMode() {
    EHGameMode::InitializeGameMode();
    if (!MatchSettings.IsValid()) MatchSettings = defaultMatchSettings;

    auto* followCamera = dynamic_cast<EHCameraFollow*>(CreateActor(FName("camera"), FVector(0, 0)));
    InitializeWorld();
    if (MatchSettings.sceneId.IsValid()) CreateActor(MatchSettings.sceneId);
    if (MatchSettings.playerSettings.size() < 2) {
        std::cerr << "Invalid size for Player Settings" << std::endl;
        return;
    }
    if (!world || world->GetSpawnPoints().size() < MatchSettings.playerSettings.size()) {
        std::cerr << "Fighting world must define a spawn point for each player" << std::endl;
        return;
    }
    EHDataTableManager* dataTableManager = EHGameInstance::GetInstance()->GetDataTableManager();
    std::size_t i = 0;
    for (const auto& playerSettings : MatchSettings.playerSettings) {
        auto* controller = dynamic_cast<EHController*>(CreateActor(playerSettings.controllerType));
        if (auto* playerController = dynamic_cast<EHPlayerController*>(controller)) playerController->SetInputDeviceId(playerSettings.inputDeviceId);
        AddController(controller);
        EHCharacterTableRow characterData;
        if (!dataTableManager->GetCharacterDataById(playerSettings.characterId, characterData)) {
            std::cout << "InitializeGameMode() - Failed to find Character Data with id: " << playerSettings.characterId.GetKey() << std::endl;
        }
        auto* character = dynamic_cast<EHCharacter*>(CreateActor(characterData.GetAssetId()));
        character->AssignController(controller);
        character->SetPosition(world->GetSpawnPoints()[i]);
        if (followCamera) followCamera->AddTargetActor(character);
        EHPaletteComponent* palette = character->GetPaletteComponent();
        palette->ApplyColorPalette(playerSettings.characterId, playerSettings.colorSelection);
        if (EHCharacterMovementComponent* movement = dynamic_cast<EHCharacterMovementComponent*>(character->GetActorComponent(FName("movement")))) movement->SetIsFacingLeft(i % 2 == 0);
        i++;
    }
}

void EHGameModeFighting::TickGameMode(float deltaTime) {
    for (EHController* controller : controllers) {
        controller->TickController(gameFrame);
    }
    EHGameMode::TickGameMode(deltaTime);
    gameFrame++;
}

void EHGameModeFighting::InitializeWorld() {
    if (!world) world = dynamic_cast<EHWorld*>(CreateActor(WorldAssetId));
}

void EHGameModeFighting::Simulate(float deltaTime) {
    EHPhysicsSystem::Step(GetActors(), deltaTime, world);
}

void EHGameModeFighting::DestroyActor(EHActor* actor) {
    if (actor == world) world = nullptr;
    EHGameMode::DestroyActor(actor);
}
