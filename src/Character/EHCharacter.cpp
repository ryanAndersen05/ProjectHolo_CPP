#include "EHCharacter.h"

EHCharacter::EHCharacter() {
    animator = new EHAnimatorComponent();
    AddComponent(FName("Animator"), animator);
}
