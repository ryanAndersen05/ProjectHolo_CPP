#pragma once
#include "nlohmann/json.hpp"
#include "core/EHActorComponent.h"
#include "library/EHLibrary.h"

using json = nlohmann::json;

class EHPhysicsComponent : public EHActorComponent, public ITickable {
public:
    static constexpr float GravityConst = 9.8f;
private:
    FVector velocity;
    bool useGravity;
    float gravityScale;
    bool useTerminalVelocity;
    float terminalVelocity;

public:
    EHPhysicsComponent() : EHActorComponent(), velocity(FVector::Zero), useGravity(true), gravityScale(1.0f), useTerminalVelocity(true), terminalVelocity(0.0f) {}
    void Tick(float deltaTime) override;
    void UpdateVelocityFromGravity(float deltaTime);
    void UpdatePositionFromVelocity(float deltaTime);

    friend void from_json(const json& j, EHPhysicsComponent &physics);
};
