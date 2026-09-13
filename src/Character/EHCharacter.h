#pragma once
#include "EHPaletteComponent.h"
#include "core/EHActor.h"
#include "core/EHController.h"


class EHCharacter : public EHActor {
private:
    EHController* controller;
public:
    EHCharacter();
    [[nodiscard]] EHPaletteComponent* GetPaletteComponent() const { return dynamic_cast<EHPaletteComponent*>(GetActorComponent(FName("palette"))); }
};