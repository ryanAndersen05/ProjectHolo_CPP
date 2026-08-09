#include "core/EHActor.h"
#include "animation/EHAnimatorComponent.h"


class EHCharacter : EHActor {
private:
    EHAnimatorComponent* animator;

public:
    EHCharacter();
};