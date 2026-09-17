#pragma once
#include "EHPaletteComponent.h"
#include "core/EHActor.h"
#include "core/EHController.h"
#include "core/EHPawn.h"


class EHCharacter : public EHPawn {
private:
    EHController* controller;
public:
    EHCharacter();
    [[nodiscard]] EHPaletteComponent* GetPaletteComponent() const { return dynamic_cast<EHPaletteComponent*>(GetActorComponent(FName("palette"))); }
};
