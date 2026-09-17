#pragma once
#include "core/EHActorComponent.h"
#include "animation/EHAnimatorComponent.h"
#include "nlohmann/json.hpp"
#include "physics/EHPhyicsComponent.h"

using json = nlohmann::json;

enum class EMovementType {
    None,
    Idle,
    Walk,
    WalkBack,
    Dash,
    DashBack,
    Crouch,
};

class EHCharacterMovementComponent : public EHActorComponent, public ITickable {
private:
    const static FName Anim_VVelocity;
    const static FName Anim_IsInAir;

    bool isFacingLeft;
    float maxWalkSpeed;
    float maxBackWalkSpeed;
    float maxDashSpeed;
    float maxBackDashSpeed;

    // float jumpHeight;
    // float jumpApexTime;
    // float horizontalJumpSpeed;
    // int maxDoubleJumps;
    float jumpVelocity;
    float jumpTime;
    float jumpHeight;
    float acceleration;

    EHAnimatorComponent* cachedAnimator;
    float goalVelocity;
    EMovementType movementType;
    EHPhysicsComponent* cachedPhysics;

public:
    EHCharacterMovementComponent();
    void Tick(float deltaTime) override;
    void InitializeComponent(EHActor* actr) override;
    void SetMovementType(EMovementType moveType);
    void AttemptJump() const;
    void AttemptAirDash();

    void SetIsFacingLeft(bool isLeft);
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHCharacterMovementComponent, maxWalkSpeed, maxBackWalkSpeed, maxDashSpeed,
        maxBackDashSpeed, jumpTime, jumpHeight, acceleration)
};
