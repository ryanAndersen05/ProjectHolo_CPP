#include "EHCharacterMovementComponent.h"
#include "factory/EHActorComponentFactory.h"

const FName EHCharacterMovementComponent::Anim_VVelocity = FName("vVelocity");
const FName EHCharacterMovementComponent::Anim_IsInAir = FName("inAir");

EHCharacterMovementComponent::EHCharacterMovementComponent() : EHActorComponent(){
    isFacingLeft = false;

    maxWalkSpeed = 5.f;
    maxBackWalkSpeed = 3.f;
    maxDashSpeed = 10.f;
    maxBackDashSpeed = 8.f;

    jumpHeight = 0.f;
    jumpTime = 0.f;
    jumpVelocity = 0.f;

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
    jumpVelocity = 2 * jumpHeight / jumpTime;
    cachedPhysics->SetGravityScale(2 * jumpHeight / jumpTime / jumpTime / EHPhysicsComponent::GravityConst);
}

void EHCharacterMovementComponent::Tick(float deltaTime) {
    FVector velocity = cachedPhysics->GetVelocity();
    cachedAnimator->SetFloat(Anim_VVelocity, velocity.y);
    cachedAnimator->SetBool(Anim_IsInAir, velocity.y != 0.f);

    if (movementType == EMovementType::None) return;
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

void EHCharacterMovementComponent::AttemptJump() const {
    FVector velocity = cachedPhysics->GetVelocity();
    velocity.y = jumpVelocity;
    cachedPhysics->SetVelocity(velocity);
}

void EHCharacterMovementComponent::SetIsFacingLeft(bool isLeft) {
    isFacingLeft = isLeft;
}

