#include "EHCharacter.h"

const FName EHCharacter::AnimatorId = FName("Animator");
const FName EHCharacter::SpriteId = FName("Sprite");

EHCharacter::EHCharacter() {
    animator = new EHAnimatorComponent();
    AddComponent(AnimatorId, animator);
    spriteComponent = new EHSpriteComponent();
    AddComponent(SpriteId, spriteComponent);
}
