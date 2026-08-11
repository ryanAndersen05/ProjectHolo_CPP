#pragma once
#include "core/EHActor.h"
#include "core/EHController.h"


class EHCharacter : public EHActor {
private:
    EHController* controller;
public:
    EHCharacter();
};