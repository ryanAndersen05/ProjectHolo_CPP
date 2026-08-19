#include "EHGameModeFactory.h"
#include "gamemode/EHGameModeFighting.h"
#include "gamemode/EHGameModeReplay.h"
#include <iostream>

#include "gamemode/EHGameModeTraining.h"

const FName EHGameModeFactory::DefaultGameMode = FName("defaultGameMode");
const FName EHGameModeFactory::FightingGameMode = FName("fightingGameMode");
const FName EHGameModeFactory::ReplayGameMode = FName("replayGameMode");
const FName EHGameModeFactory::TrainingGameMode = FName("trainingGameMode");

EHGameMode *EHGameModeFactory::CreateGameMode(const FName& gameModeType, const json&) {
    EHGameMode* newGameMode = nullptr;
    if (gameModeType == EHGameModeFactory::DefaultGameMode) newGameMode = new EHGameMode();
    if (gameModeType == EHGameModeFactory::FightingGameMode) newGameMode = new EHGameModeFighting();
    if (gameModeType == EHGameModeFactory::ReplayGameMode) newGameMode = new EHGameModeReplay();
    if (gameModeType == EHGameModeFactory::TrainingGameMode) newGameMode = new EHGameModeTraining();
    return newGameMode;

}
