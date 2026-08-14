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