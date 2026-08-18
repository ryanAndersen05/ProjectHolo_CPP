#include "EHGameInstance.h"
#include <iostream>
#include "library/EHJsonManager.h"

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
    std::cout << "World Settings Mode: " << worldSettings.gameModePath << " GameHUD: " << worldSettings.gameHUDPath << std::endl;
}

void EHGameInstance::TickGame() {

}

void EHGameInstance::DisplayGame() {

}
