#include "EHBoxColliderComponent.h"
#include <cmath>
#include <stdexcept>

bool EHBoxColliderComponent::SetBounds(const FVector& newSize, const FVector& newOffset) {
    if (newSize.x < 0.f || newSize.y < 0.f || newOffset.y < 0.f) return false;
    size = newSize;
    offset = newOffset;
    return true;
}

FRect EHBoxColliderComponent::GetLocalBounds() const {
    return FRect(FVector(offset.x - size.x * 0.5f, offset.y), size);
}

std::optional<FRect> EHBoxColliderComponent::GetWorldBounds() const {
    if (!GetActor()) {
        std::cout << "GetWorldBounds() - Invalid Actor" << std::endl;
        return std::nullopt;
    }
    const FVector scale = GetActorScale();
    const FVector worldSize(size.x * std::abs(scale.x), size.y * std::abs(scale.y));
    // Even a negative Y scale keeps the body above the actor's feet.
    const FVector bottomCenter = GetActorPosition()
        + FVector(offset.x * scale.x, offset.y * std::abs(scale.y));
    const FVector minimum(bottomCenter.x - worldSize.x * 0.5f, bottomCenter.y);
    return FRect(minimum, worldSize);
}

void from_json(const json& data, EHBoxColliderComponent& collider) {
    const FVector size = data.at("size").get<FVector>();
    const FVector offset = data.value("offset", FVector::Zero);
    if (!collider.SetBounds(size, offset)) throw std::invalid_argument("Invalid box collider bounds");
}
