//
// Created by ryana on 8/12/2026.
//

#include "EHGameModeFighting.h"

void EHGameModeFighting::InitializeGameMode() {
    EHGameMode::InitializeGameMode();
    CreateActor(FName("gura"), FVector::Zero);
}
