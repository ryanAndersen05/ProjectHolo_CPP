#pragma once
#include "core/EHActorComponent.h"
#include "animation/EHAnimatorComponent.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

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

    void SetIsFacingLeft(bool isLeft);
    friend void from_json(const json& j, EHCharacterMovementComponent &component);
};
