#pragma once
#include "core/EHActorComponent.h"
#include "animation/EHAnimatorComponent.h"
#include "nlohmann/json.hpp"

class EHCharacterMovementComponent : public EHActorComponent, public ITickable {
private:
    const static FName Anim_VVelocity;
    const static FName Anim_Jump;
    const static FName Anim_IsInAir;
    const static FName Anim_DashBackward;
    const static FName Anim_DashForward;
    const static FName Anim_HorizontalInput;

    bool isFacingLeft;
    float maxWalkSpeed;
    float maxBackWalkSpeed;
    float maxDashSpeed;
    float maxBackDashSpeed;

    float maxAirDashSpeed;
    float maxAirBackDashSpeed;
    int maxAirDashes;

    float jumpHeight;
    float jumpApexTime;
    float horizontalJumpSpeed;
    int maxDoubleJumps;

    EHAnimatorComponent* cachedAnimator;

public:
    EHCharacterMovementComponent();
    void Tick(float deltaTime) override;
    void InitializeComponent(EHActor *actr) override;

    NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(EHCharacterMovementComponent, maxWalkSpeed, maxBackWalkSpeed, maxDashSpeed, maxBackDashSpeed,
        maxAirDashSpeed, maxAirBackDashSpeed, maxAirDashes, jumpHeight, jumpApexTime, horizontalJumpSpeed, maxDoubleJumps);
};