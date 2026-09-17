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

    // maxAirDashSpeed = 10.f;
    // maxAirBackDashSpeed = 8.f;
    // maxAirDashes = 1;
    //
    // jumpHeight = 1.f;
    // jumpApexTime = 1.f;
    // horizontalJumpSpeed = 5.f;
    // maxDoubleJumps = 1;

    cachedAnimator = nullptr;
    goalVelocity = 0.f;
    movementType = EMovementType::None;
    acceleration = 0.f;
    cachedPhysics = nullptr;
}

void EHCharacterMovementComponent::InitializeComponent(EHActor *actr)  {
    EHActorComponent::InitializeComponent(actr);
    cachedAnimator = dynamic_cast<EHAnimatorComponent*>(actr->GetActorComponent(EHActorComponentFactory::AnimatorComponentId));
    cachedPhysics = dynamic_cast<EHPhysicsComponent*>(actr->GetActorComponent(EHActorComponentFactory::PhysicsComponentId));
}

void EHCharacterMovementComponent::Tick(float deltaTime) {
    if (movementType == EMovementType::None) return;
    FVector velocity = cachedPhysics->GetVelocity();
    float adjustedGoalVelocity = goalVelocity * (isFacingLeft ? -1.f : 1.f);
    velocity.x = EHMath::MoveTowards(velocity.x, adjustedGoalVelocity, acceleration * deltaTime);
    cachedPhysics->SetVelocity(velocity);
}

void EHCharacterMovementComponent::SetMovementType(EMovementType moveType) {
    if (moveType == movementType) return;
    movementType = moveType;
    switch (movementType) {
        case EMovementType::None: goalVelocity = 0; break;
        case EMovementType::Idle: goalVelocity = 0; break;
        case EMovementType::Walk: goalVelocity = maxWalkSpeed; break;
        case EMovementType::WalkBack: goalVelocity = -maxBackWalkSpeed; break;
        case EMovementType::Crouch: goalVelocity = 0.f; break;
        default:
            std::cout << "SetMovementType() - Movement Type not implemented" << std::endl;
            break;
    }
}

void EHCharacterMovementComponent::SetIsFacingLeft(bool isLeft) {
    isFacingLeft = isLeft;
}

