#pragma once
#include "core/EHActor.h"
#include <optional>

class EHWorld : public EHActor {
private:
    std::vector<FVector> spawnPoints = {FVector(-3.f, 0.f), FVector(3.f, 0.f)};
    float worldSize = 15.f;
public:
    [[nodiscard]] const std::vector<FVector>& GetSpawnPoints() const { return spawnPoints; }
    [[nodiscard]] std::optional<FVector> GetSpawnPoint(std::size_t playerIndex) const;
    [[nodiscard]] float GetWorldSize() const { return worldSize; }
    [[nodiscard]] float GetMinX() const { return -worldSize * 0.5f; }
    [[nodiscard]] float GetMaxX() const { return worldSize * 0.5f; }
    [[nodiscard]] FVector ClampPosition(const FVector& position) const;
    friend void from_json(const json& data, EHWorld& world);
};
