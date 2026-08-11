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
}

// void EHGameInstance::InitializeGame(const FWorldSettings& worldSettings) {
//     delete gameMode;
//     delete gameHUD;
//
//
// }

void EHGameInstance::TickGame() {

}

void EHGameInstance::DisplayGame() {

}
