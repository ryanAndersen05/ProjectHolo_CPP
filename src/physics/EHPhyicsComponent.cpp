#include "EHPhyicsComponent.h"

void EHPhysicsComponent::Tick(float deltaTime) {
    if (useGravity) UpdateVelocityFromGravity(deltaTime);
}

void EHPhysicsComponent::UpdateVelocityFromGravity(float deltaTime) {
    velocity.y -= gravityScale * GravityConst * deltaTime;
    if (useTerminalVelocity) velocity.y = std::max(velocity.y, -terminalVelocity);
}

void EHPhysicsComponent::UpdatePositionFromVelocity(float deltaTime) {
    SetActorPosition(GetActorPosition() + (velocity * deltaTime));
}

void from_json(const json& j, EHPhysicsComponent& physics) {
    j.at("useGravity").get_to(physics.useGravity);
    j.at("gravityScale").get_to(physics.gravityScale);
    j.at("useTerminalVelocity").get_to(physics.useTerminalVelocity);
    j.at("terminalVelocity").get_to(physics.terminalVelocity);
}
