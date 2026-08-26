//
// Created by ryana on 8/12/2026.
//

#include "EHGameModeFighting.h"

void EHGameModeFighting::InitializeGameMode() {
    EHGameMode::InitializeGameMode();

    CreateActor(FName("camera"), FVector(0, 0));
    CreateActor(FName("gura"), FVector(-1.5f, 0.f));
    CreateActor(FName("kiara"), FVector(1.5f, 1.5f));
}
