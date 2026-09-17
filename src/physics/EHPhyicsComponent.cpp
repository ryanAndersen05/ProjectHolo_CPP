#include "EHPhyicsComponent.h"

void EHPhysicsComponent::Tick(float deltaTime) {
    if (useGravity) UpdateVelocityFromGravity(deltaTime);
    UpdatePositionFromVelocity(deltaTime);
}

void EHPhysicsComponent::UpdateVelocityFromGravity(float deltaTime) {
    velocity.y -= gravityScale * GravityConst * deltaTime;
    if (useTerminalVelocity) velocity.y = std::max(velocity.y, -terminalVelocity);
}

void EHPhysicsComponent::UpdatePositionFromVelocity(float deltaTime) {
    FVector position = GetActorPosition();
    position = position + (velocity * deltaTime);
    if (position.y <= 0.f) {
        velocity.y = 0.f;
        position.y = 0.f;
    }
    SetActorPosition(position);
}

void from_json(const json& j, EHPhysicsComponent& physics) {
    j.at("useGravity").get_to(physics.useGravity);
    j.at("gravityScale").get_to(physics.gravityScale);
    j.at("useTerminalVelocity").get_to(physics.useTerminalVelocity);
    j.at("terminalVelocity").get_to(physics.terminalVelocity);
}
