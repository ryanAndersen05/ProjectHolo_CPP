#include "EHGura.h"
#include "animation/EHAnimatorComponent.h"

EHGura::EHGura() : EHCharacter() {
    animator->InitializeAnimatorController("assets/animation/gura/gura_animator.json");
}
