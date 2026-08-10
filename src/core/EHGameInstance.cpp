#include "EHGameInstance.h"

#include <iostream>

EHGameInstance* EHGameInstance::instance = nullptr;

EHGameInstance::EHGameInstance() {
    if (instance != nullptr) {
        std::cout << "EHGameInstance already exists. You should never try to make two." << std::endl;
        return;
    }
    EHGameInstance::instance = this;
    spriteManager = new EHSpriteManager();
}

void EHGameInstance::InitializeGame() {
    std::cout << "Game Is Initialized" << std::endl;
}
