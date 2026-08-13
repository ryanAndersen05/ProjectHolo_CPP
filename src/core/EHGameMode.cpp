#include "EHGameMode.h"

#include <iostream>

EHGameMode::EHGameMode() = default;
EHGameMode::~EHGameMode() = default;

void EHGameMode::AddController(const FName &controllerId) {
    std::cout << controllerId.GetKey() << std::endl;
}
