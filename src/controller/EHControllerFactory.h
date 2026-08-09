#pragma once
#include "core/EHController.h"
enum EControllerType {
    Player,
    AIController,
};

class EHControllerFactory {
public:
    EHController* CreateController(EControllerType controllerType);
};