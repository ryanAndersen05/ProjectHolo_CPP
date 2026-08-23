#pragma once
#include "core/EHGameMode.h"

class EHGameModeFighting : public EHGameMode{
public:
    EHGameModeFighting() : EHGameMode(){}
    void InitializeGameMode() override;
    void TickGameMode() override;
};
