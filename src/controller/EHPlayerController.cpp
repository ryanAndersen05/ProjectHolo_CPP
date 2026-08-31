#include "EHPlayerController.h"
#include <bitset>
#include <iostream>
#include "core/EHGameInstance.h"
#include "library/EHLibrary.h"

EHPlayerController::EHPlayerController() : EHController(), cachedButton(EButton::None), previousButton(EButton::None) {
    if (!EHGameInstance::LoadAsset(FName("default_game_input"), inputMap)) {

    }
}

void EHPlayerController::ModifyCachedButton(EButton button, bool isPressed) {
    if (isPressed) {
        cachedButton = static_cast<EButton>(cachedButton | button);
    }
    else {
        cachedButton = static_cast<EButton>(cachedButton & ~button);
    }
    if (previousButton!=cachedButton) {
        std::cout << std::bitset<8>(cachedButton) << std::endl;
        previousButton = cachedButton;
    }
}
