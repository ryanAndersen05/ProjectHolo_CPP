#include "EHCharacterMovementComponent.h"
#include "factory/EHActorComponentFactory.h"

const FName EHCharacterMovementComponent::Anim_VVelocity = FName("VVelocity");
const FName EHCharacterMovementComponent::Anim_Jump = FName("Jump");
const FName EHCharacterMovementComponent::Anim_IsInAir = FName("IsInAir");
const FName EHCharacterMovementComponent::Anim_DashForward = FName("DashF");
const FName EHCharacterMovementComponent::Anim_DashBackward = FName("DashB");
const FName EHCharacterMovementComponent::Anim_HorizontalInput = FName("HInput");

EHCharacterMovementComponent::EHCharacterMovementComponent() : EHActorComponent(){
    isFacingLeft = false;

    maxWalkSpeed = 5.f;
    maxBackWalkSpeed = 3.f;
    maxDashSpeed = 10.f;
    maxBackDashSpeed = 8.f;

    maxAirDashSpeed = 10.f;
    maxAirBackDashSpeed = 8.f;
    maxAirDashes = 1;

    jumpHeight = 1.f;
    jumpApexTime = 1.f;
    horizontalJumpSpeed = 5.f;
    maxDoubleJumps = 1;

    cachedAnimator = nullptr;
}

void EHCharacterMovementComponent::InitializeComponent(EHActor *actr)  {
     EHActorComponent::InitializeComponent(actr);
     cachedAnimator = dynamic_cast<EHAnimatorComponent *>(actr->GetActorComponent(EHActorComponentFactory::AnimatorComponentId));
}

void EHCharacterMovementComponent::Tick(float) {
    // float yPos = GetActorPosition().y;
    // if (cachedAnimator) {
    // }
}

void EHCharacterMovementComponent::SetIsFacingLeft(bool isLeft) {
    isFacingLeft = isLeft;
}

