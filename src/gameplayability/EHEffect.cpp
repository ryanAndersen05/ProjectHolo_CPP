//
// Created by ryana on 11/4/2026.
//

#include "EHEffect.h"
#include <cmath>
#include <stdexcept>

NLOHMANN_JSON_SERIALIZE_ENUM_STRICT(EEffectType, {
    {EEffectType::Instant, "Instant"}, {EEffectType::Duration, "Duration"}, {EEffectType::Infinite, "Infinite"}
});
NLOHMANN_JSON_SERIALIZE_ENUM_STRICT(EAttributeModifierType, {
    {EAttributeModifierType::Set, "Set"}, {EAttributeModifierType::Add, "Add"},
    {EAttributeModifierType::Subtract, "Subtract"}, {EAttributeModifierType::Multiply, "Multiply"},
    {EAttributeModifierType::Divide, "Divide"}
});

void from_json(const json& data, FGameplayTagGrant& grant) {
    grant.tag = data.at("tag").get<FName>();
    grant.count = data.value("count", 1);
    if (grant.tag.GetKey().empty() || grant.count <= 0) throw std::invalid_argument("Invalid gameplay tag grant");
}

void from_json(const json& data, EHEffect& effect) {
    EHEffect parsed;
    parsed.type = data.at("type").get<EEffectType>();
    parsed.durationFrames = data.value("durationFrames", 0);
    parsed.tags = data.value("tags", std::vector<FGameplayTagGrant>{});
    if (parsed.type == EEffectType::Duration && parsed.durationFrames <= 0)
        throw std::invalid_argument("Duration effects require positive durationFrames");
    if (parsed.type == EEffectType::Instant && !parsed.tags.empty())
        throw std::invalid_argument("Instant effects cannot own persistent tags");
    for (const auto& entry : data.value("modifiers", json::array())) {
        FAttributeModifier modifier;
        modifier.attribute = entry.at("attribute").get<FName>();
        modifier.type = entry.at("type").get<EAttributeModifierType>();
        modifier.value = entry.at("value").get<float>();
        if (modifier.attribute.GetKey().empty() || !std::isfinite(modifier.value) ||
            (modifier.type == EAttributeModifierType::Divide && modifier.value == 0.f))
            throw std::invalid_argument("Invalid attribute modifier");
        parsed.modifiers.push_back(modifier);
    }
    effect = std::move(parsed);
}
