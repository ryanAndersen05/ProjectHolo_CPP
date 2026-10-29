#pragma once
#include "EHHitbox.h"
#include "core/EHActorComponent.h"
#include <optional>
#include <unordered_map>

class EHHitboxComponent : public EHActorComponent {
private:
    std::unordered_map<FName, EHHitbox> hitboxes;

    void LoadHitboxes(const json& data);

public:
    [[nodiscard]] bool HasHitbox(const FName& name) const;
    [[nodiscard]] std::optional<EHHitboxType> GetType(const FName& name) const;
    [[nodiscard]] std::optional<bool> IsActive(const FName& name) const;
    [[nodiscard]] std::optional<FVector> GetPosition(const FName& name) const;
    [[nodiscard]] std::optional<FVector> GetSize(const FName& name) const;
    [[nodiscard]] std::optional<FRect> GetLocalBounds(const FName& name) const;
    [[nodiscard]] std::optional<FRect> GetWorldBounds(const FName& name) const;

    bool SetActive(const FName& name, bool active);
    // Positions are actor-local bottom-left corners. Sizes must be nonnegative.
    bool SetPosition(const FName& name, const FVector& position);
    bool SetSize(const FName& name, const FVector& size);
    bool SetBounds(const FName& name, const FVector& position, const FVector& size);

    bool DoesHitboxOverlap(const FName& name, const FRect& rect) const;

    friend void from_json(const json& data, EHHitboxComponent& component);
};
