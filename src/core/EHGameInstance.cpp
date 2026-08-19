#include "EHGameInstance.h"
#include <iostream>
#include "factory/EHGameModeFactory.h"

EHGameInstance* EHGameInstance::instance = nullptr;

EHGameInstance::EHGameInstance() : gameMode(nullptr), gameHUD(nullptr) {
    if (instance != nullptr) {
        std::cout << "EHGameInstance already exists. You should never try to make two." << std::endl;
        return;
    }
    EHGameInstance::instance = this;
    spriteManager = new EHSpriteManager();
    dataTableManager = new EHDataTableManager();
}

EHGameInstance::~EHGameInstance() {
    delete spriteManager;
    delete dataTableManager;
}

void EHGameInstance::InitializeGame(const FWorldSettings &worldSettings) {
    delete gameMode;
    delete gameHUD;

    json gameModeJson;
    if (!EHJsonManager::DeserializeAsJson(worldSettings.gameModePath, gameModeJson)) {
        std::cout << "Failed to Deserialize GameMode" << std::endl;
        return;
    }
    FName gameModeType = gameModeJson.at("gameModeType").get<FName>();
    gameMode = EHGameModeFactory::CreateGameMode(gameModeType, gameModeJson.at("data"));
    if (gameMode != nullptr) gameMode->InitializeGameMode();
}

void EHGameInstance::TickGame() {
    if (gameMode != nullptr) gameMode->TickGameMode();
    if (gameHUD != nullptr) gameHUD->TickGameHUD();
}

void EHGameInstance::DisplayGame() {

}


