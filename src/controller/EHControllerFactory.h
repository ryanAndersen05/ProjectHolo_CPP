#pragma once
#include "core/EHController.h"
enum class EControllerType {
    Player,
    AIController,
};

class EHControllerFactory {
public:
    EHController* CreateController(EControllerType controllerType);
};