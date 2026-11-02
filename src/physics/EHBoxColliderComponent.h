#pragma once
#include "core/EHActorComponent.h"
#include <optional>

// Axis-aligned character body. Offset identifies the bottom-center above the feet.
class EHBoxColliderComponent : public EHActorComponent {
private:
    FVector size = FVector(1.f, 2.f);
    FVector offset = FVector::Zero;
public:
    bool SetBounds(const FVector& newSize, const FVector& newOffset);
    [[nodiscard]] FVector GetSize() const { return size; }
    [[nodiscard]] FVector GetOffset() const { return offset; }
    [[nodiscard]] FRect GetLocalBounds() const;
    [[nodiscard]] std::optional<FRect> GetWorldBounds() const;
    friend void from_json(const json& data, EHBoxColliderComponent& collider);
};
