#pragma once
#include "core/EHActor.h"
#include "animation/EHAnimatorComponent.h"
#include "sprite/EHSpriteComponent.h"


class EHCharacter : public EHActor {
public:
    static const FName AnimatorId ;
    static const FName SpriteId;

protected:
    EHAnimatorComponent* animator;
    EHSpriteComponent* spriteComponent;

public:
    EHCharacter();
};