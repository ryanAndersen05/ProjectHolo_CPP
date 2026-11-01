#include "EHHitboxComponent.h"
#include "gamemode/EHGameModeTraining.h"
#include <algorithm>
#include <cmath>
#include <stdexcept>
#include <utility>

namespace {
    constexpr std::pair<EHitboxType, EHitboxType> OverlapTypePairs[] = {
        {EHitboxType::Hitbox, EHitboxType::Hurtbox}
    };

    bool IsValidBounds(const FVector& position, const FVector& size) {
        return std::isfinite(position.x) && std::isfinite(position.y)
            && std::isfinite(size.x) && std::isfinite(size.y)
            && size.x >= 0.f && size.y >= 0.f
            && std::isfinite(position.x + size.x) && std::isfinite(position.y + size.y);
    }
}

bool EHHitboxComponent::HasHitbox(const FName& name) const {
    return hitboxes.contains(name);
}

std::optional<EHitboxType> EHHitboxComponent::GetType(const FName& name) const {
    const auto found = hitboxes.find(name);
    if (found == hitboxes.end()) return std::nullopt;
    return found->second.type;
}

std::optional<bool> EHHitboxComponent::IsActive(const FName& name) const {
    const auto found = hitboxes.find(name);
    if (found == hitboxes.end()) return std::nullopt;
    return found->second.isActive;
}

std::optional<FVector> EHHitboxComponent::GetPosition(const FName& name) const {
    const auto bounds = GetLocalBounds(name);
    if (!bounds) return std::nullopt;
    return bounds->GetPosition();
}

std::optional<FVector> EHHitboxComponent::GetSize(const FName& name) const {
    const auto bounds = GetLocalBounds(name);
    if (!bounds) return std::nullopt;
    return bounds->GetSize();
}

std::optional<FRect> EHHitboxComponent::GetLocalBounds(const FName& name) const {
    const auto found = hitboxes.find(name);
    if (found == hitboxes.end()) return std::nullopt;
    return found->second.localBounds;
}

std::optional<FRect> EHHitboxComponent::GetWorldBounds(const FName& name) const {
    const auto bounds = GetLocalBounds(name);
    if (!bounds || !GetActor()) return std::nullopt;

    const FVector position = GetActorPosition();
    const FVector scale = GetActorScale();
    const FVector localMin = bounds->GetPosition();
    const FVector localMax = localMin + bounds->GetSize();
    const FVector first(position.x + localMin.x * scale.x, position.y + localMin.y * scale.y);
    const FVector second(position.x + localMax.x * scale.x, position.y + localMax.y * scale.y);
    const FVector minimum(std::min(first.x, second.x), std::min(first.y, second.y));
    const FVector maximum(std::max(first.x, second.x), std::max(first.y, second.y));
    return FRect(minimum, maximum - minimum);
}

bool EHHitboxComponent::SetActive(const FName& name, bool active) {
    const auto found = hitboxes.find(name);
    if (found == hitboxes.end()) return false;
    EHHitbox& box = found->second;
    if (box.isActive == active) return true;

    auto& activeNames = activeHitboxes[box.type];
    if (active) activeNames.push_back(name);
    else std::erase(activeNames, name);
    box.isActive = active;
    return true;
}

bool EHHitboxComponent::SetPosition(const FName& name, const FVector& position) {
    const auto size = GetSize(name);
    return size && SetBounds(name, position, *size);
}

bool EHHitboxComponent::SetSize(const FName& name, const FVector& size) {
    const auto position = GetPosition(name);
    return position && SetBounds(name, *position, size);
}

bool EHHitboxComponent::SetBounds(const FName& name, const FVector& position, const FVector& size) {
    const auto found = hitboxes.find(name);
    if (found == hitboxes.end() || !IsValidBounds(position, size)) return false;
    found->second.localBounds = FRect(position, size);
    return true;
}

bool EHHitboxComponent::DoesHitboxComponentOverlap(const EHHitboxComponent* otherComponent, FVector& outHitPosition) {
    if (!otherComponent || otherComponent == this || !GetActor() || !otherComponent->GetActor()) return false;
    if (std::find(overlappingComponents.begin(), overlappingComponents.end(), otherComponent)
        != overlappingComponents.end()) return false;

    for (const auto& [sourceType, targetType] : OverlapTypePairs) {
        const auto sourceNames = activeHitboxes.find(sourceType);
        const auto targetNames = otherComponent->activeHitboxes.find(targetType);
        if (sourceNames == activeHitboxes.end() || targetNames == otherComponent->activeHitboxes.end()) continue;

        for (const FName& sourceName : sourceNames->second) {
            const auto sourceBounds = GetWorldBounds(sourceName);
            if (!sourceBounds) continue;

            for (const FName& targetName : targetNames->second) {
                const auto targetBounds = otherComponent->GetWorldBounds(targetName);
                if (!targetBounds || !sourceBounds->IsOverlapping(*targetBounds, outHitPosition)) continue;

                overlappingComponents.push_back(otherComponent);
                return true;
            }
        }
    }
    return false;
}

void EHHitboxComponent::LoadHitboxes(const json& data) {
    const auto& definitions = data.at("hitboxes");
    if (!definitions.is_array()) {
        throw std::invalid_argument("Hitbox component: 'hitboxes' must be an array");
    }

    // Only replace existing state after every definition has been validated.
    std::unordered_map<FName, EHHitbox> loaded;
    std::unordered_map<EHitboxType, std::vector<FName>> loadedActive;
    for (const auto& definition : definitions) {
        const FName name = definition.at("name").get<FName>();
        if (!name.IsValid() || loaded.contains(name)) {
            throw std::invalid_argument("Hitbox component: empty or duplicate name '" + name.GetKey() + "'");
        }

        EHHitbox box;
        definition.at("type").get_to(box.type);

        const FVector position = definition.at("position").get<FVector>();
        const FVector size = definition.at("size").get<FVector>();
        if (!IsValidBounds(position, size)) {
            throw std::invalid_argument("Hitbox component: invalid bounds for '" + name.GetKey() + "'");
        }
        box.localBounds = FRect(position, size);
        box.isActive = definition.value("active", false);
        if (box.isActive) loadedActive[box.type].push_back(name);
        loaded.emplace(name, std::move(box));
    }
    hitboxes.swap(loaded);
    activeHitboxes.swap(loadedActive);
}

void from_json(const json& data, EHHitboxComponent& component) {
    component.LoadHitboxes(data);
}

void EHHitboxComponent::CollectDrawCommands(FRenderQueue& queue, const FRenderContext& context) const {
    if (!dynamic_cast<const EHGameModeTraining*>(context.gameMode)) return;

    for (const auto& [type, names] : activeHitboxes) {
        const sf::Color outline = type == EHitboxType::Hitbox
            ? sf::Color(255, 60, 60) : sf::Color(60, 140, 255);
        const sf::Color fill(outline.r, outline.g, outline.b, 60);
        for (const FName& name : names) {
            const auto bounds = GetWorldBounds(name);
            if (!bounds || bounds->GetSize().x <= 0.f || bounds->GetSize().y <= 0.f) continue;
            queue.debugRectangles.push_back({*bounds, fill, outline});
        }
    }
}
