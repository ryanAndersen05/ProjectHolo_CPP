#include "EHWorld.h"
#include <algorithm>
#include <cmath>
#include <stdexcept>

std::optional<FVector> EHWorld::GetSpawnPoint(std::size_t playerIndex) const {
    if (playerIndex >= spawnPoints.size()) return std::nullopt;
    return spawnPoints[playerIndex];
}

FVector EHWorld::ClampPosition(const FVector& position) const {
    return FVector(std::clamp(position.x, GetMinX(), GetMaxX()), position.y);
}

void from_json(const json& data, EHWorld& world) {
    const float size = data.at("worldSize").get<float>();
    if (!std::isfinite(size) || size <= 0.f) throw std::invalid_argument("World size must be positive and finite");
    auto spawns = data.at("spawnPoints").get<std::vector<FVector>>();
    const float halfSize = size * 0.5f;
    for (const auto& spawn : spawns) {
        if (!std::isfinite(spawn.x) || !std::isfinite(spawn.y)
            || spawn.x < -halfSize || spawn.x > halfSize || spawn.y < 0.f) {
            throw std::invalid_argument("World spawn points must be inside the horizontal bounds and above the floor");
        }
    }
    world.spawnPoints.swap(spawns);
    world.worldSize = size;
}
