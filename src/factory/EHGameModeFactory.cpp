#include "EHGameModeFactory.h"
#include "gamemode/EHGameModeFighting.h"
#include "gamemode/EHGameModeReplay.h"
#include <iostream>


EHGameMode *EHGameModeFactory::CreateGameMode(const EGameModeType gameModeType) {
    switch (gameModeType) {
        case EGameModeType::Default:
            return new EHGameMode();
        case EGameModeType::Fighting:
            return new EHGameModeFighting();
        case EGameModeType::Replay:
            return new EHGameModeReplay();
        default:
            std::cout << "CreateGameMode() - Invalid Type: " << gameModeType << std::endl;
            return nullptr;

    }

}
