//
// Created by ryana on 11/4/2026.
//

#include "EHAbilitySystemComponent.h"
#include "core/EHGameInstance.h"
#include <algorithm>
#include <cmath>
#include <set>
#include <stdexcept>

namespace {
    float Modify(float value, const FAttributeModifier& modifier) {
        switch (modifier.type) {
            case EAttributeModifierType::Set: return modifier.value;
            case EAttributeModifierType::Add: return value + modifier.value;
            case EAttributeModifierType::Subtract: return value - modifier.value;
            case EAttributeModifierType::Multiply: return value * modifier.value;
            case EAttributeModifierType::Divide: return value / modifier.value;
        }
        return value;
    }
    float ClampAttribute(float value, const FAttributeValue& attribute) {
        if (attribute.minimum) value = std::max(value, *attribute.minimum);
        if (attribute.maximum) value = std::min(value, *attribute.maximum);
        return value;
    }
    FEffectHandle NextEffectHandle() {
        static std::uint64_t nextId = 1;
        return {nextId++};
    }
}

void from_json(const json& data, EHAbilitySystemComponent& system) {
    std::map<std::string, FAttributeValue> parsed;
    const json entries = data.value("attributes", json::object());
    for (auto it = entries.begin(); it != entries.end(); ++it) {
        FAttributeValue attribute;
        attribute.baseValue = it.value().at("base").get<float>();
        if (it.value().contains("min")) attribute.minimum = it.value().at("min").get<float>();
        if (it.value().contains("max")) attribute.maximum = it.value().at("max").get<float>();
        attribute.maxAttribute = it.value().value("maxAttribute", FName{});
        if (it.key().empty() || !std::isfinite(attribute.baseValue) ||
            (attribute.minimum && !std::isfinite(*attribute.minimum)) ||
            (attribute.maximum && !std::isfinite(*attribute.maximum)) ||
            (attribute.minimum && attribute.maximum && *attribute.minimum > *attribute.maximum))
            throw std::invalid_argument("Invalid attribute definition");
        attribute.value = attribute.baseValue = ClampAttribute(attribute.baseValue, attribute);
        parsed.emplace(it.key(), attribute);
    }
    // Resolve upper-bound dependencies up front, rejecting missing/cyclic references.
    for (const auto& [name, attribute] : parsed) {
        std::set<std::string> path{name};
        FName bound = attribute.maxAttribute;
        while (!bound.GetKey().empty()) {
            const auto found = parsed.find(bound.GetKey());
            if (found == parsed.end() || !path.insert(bound.GetKey()).second)
                throw std::invalid_argument("Invalid maxAttribute dependency");
            bound = found->second.maxAttribute;
        }
    }
    system.attributes = std::move(parsed);
    system.defaultAbilities = data.value("abilities", std::vector<FName>{});
    system.RecalculateAttributes();
    system.pendingEvents.clear();
}

void EHAbilitySystemComponent::InitializeComponent(EHActor* actor) {
    EHActorComponent::InitializeComponent(actor);
    FOperation operation(*this);
    for (const auto& ability : defaultAbilities) GrantAbility(ability);
}

void EHAbilitySystemComponent::UninitializeComponent() {
    if (shuttingDown) return;
    FOperation operation(*this);
    shuttingDown = true;
    for (const auto& [name, ability] : abilities) {
        ability->pendingRemoval = true;
        ability->End();
    }
    std::vector<FEffectHandle> remaining;
    for (const auto& [id, effect] : effects) remaining.push_back({id});
    for (auto handle : remaining) RemoveEffect(handle);
}

void EHAbilitySystemComponent::Tick(float deltaTime) {
    if (deltaTime <= 0.f || shuttingDown) return;
    FOperation operation(*this);
    // New effects created by onTick start counting down on the next simulation tick.
    std::vector<FEffectHandle> expired;
    for (auto& [id, effect] : effects) {
        if (effect.definition.type == EEffectType::Duration && --effect.remainingFrames <= 0)
            expired.push_back({id});
    }
    for (auto handle : expired) RemoveEffect(handle);
    std::vector<FName> ticking;
    for (const auto& [name, ability] : abilities) if (ability->active) ticking.emplace_back(name);
    for (const auto& name : ticking) {
        if (EHAbility* ability = GetAbility(name)) {
            if (HasAnyTags(ability->blockedTags) || !HasAllTags(ability->requiredTags)) ability->End();
            else ability->Tick(deltaTime);
        }
    }
}

bool EHAbilitySystemComponent::GrantAbility(const FName& abilityId) {
    FOperation operation(*this);
    if (shuttingDown || abilityId.GetKey().empty() || abilities.contains(abilityId.GetKey())) return false;
    json definition;
    if (!EHGameInstance::LoadAssetAsJson(abilityId, definition)) return false;
    auto ability = std::make_unique<EHAbility>();
    EHAbility* instance = ability.get();
    abilities.emplace(abilityId.GetKey(), std::move(ability));
    try {
        if (!instance->Initialize(*this, abilityId, definition)) {
            instance->pendingRemoval = true;
            return false;
        }
        if (definition.value("activateOnGrant", false)) instance->Activate();
        tagsDirty = true; // Activation tags may already be present when granted.
        return true;
    } catch (const std::exception& error) {
        instance->pendingRemoval = true;
        std::cerr << "GrantAbility " << abilityId.GetKey() << ": " << error.what() << '\n';
        return false;
    }
}

EHAbility* EHAbilitySystemComponent::GetAbility(const FName& abilityId) const {
    const auto found = abilities.find(abilityId.GetKey());
    return found == abilities.end() || found->second->pendingRemoval ? nullptr : found->second.get();
}

bool EHAbilitySystemComponent::RemoveAbility(const FName& abilityId) {
    FOperation operation(*this);
    EHAbility* ability = GetAbility(abilityId);
    if (!ability) return false;
    ability->pendingRemoval = true;
    ability->End();
    return true;
}

bool EHAbilitySystemComponent::ActivateAbility(const FName& abilityId, EHActor* target) {
    FOperation operation(*this);
    EHAbility* ability = GetAbility(abilityId);
    return ability && ability->Activate(target);
}

bool EHAbilitySystemComponent::EndAbility(const FName& abilityId) {
    FOperation operation(*this);
    EHAbility* ability = GetAbility(abilityId);
    if (!ability || !ability->active) return false;
    ability->End();
    return true;
}

std::optional<float> EHAbilitySystemComponent::GetAttribute(const FName& name) const {
    const auto found = attributes.find(name.GetKey());
    if (found == attributes.end()) return std::nullopt;
    return found->second.value;
}

std::optional<float> EHAbilitySystemComponent::GetBaseAttribute(const FName& name) const {
    const auto found = attributes.find(name.GetKey());
    if (found == attributes.end()) return std::nullopt;
    return found->second.baseValue;
}

bool EHAbilitySystemComponent::SetBaseAttribute(const FName& name, float value) {
    FOperation operation(*this);
    auto found = attributes.find(name.GetKey());
    if (found == attributes.end()) return false;
    found->second.baseValue = value;
    RecalculateAttributes();
    return true;
}

bool EHAbilitySystemComponent::HasAllTags(const std::vector<FName>& names) const {
    return std::ranges::all_of(names, [this](const FName& name) { return HasTag(name); });
}

bool EHAbilitySystemComponent::HasAnyTags(const std::vector<FName>& names) const {
    return std::ranges::any_of(names, [this](const FName& name) { return HasTag(name); });
}

int EHAbilitySystemComponent::GetTagCount(const FName& tag) const {
    const auto found = tags.find(tag.GetKey());
    return found == tags.end() ? 0 : found->second;
}

void EHAbilitySystemComponent::AddTag(const FName& tag, int count) {
    FOperation operation(*this);
    if (tag.GetKey().empty() || count <= 0 || shuttingDown) return;
    const int previous = GetTagCount(tag);
    tags[tag.GetKey()] = previous + count;
    pendingEvents.push_back({tag, static_cast<float>(previous), static_cast<float>(previous + count), EEventType::Tag});
    tagsDirty = true;
}

void EHAbilitySystemComponent::RemoveTag(const FName& tag, int count) {
    FOperation operation(*this);
    if (count <= 0) return;
    const int previous = GetTagCount(tag);
    const int next = std::max(0, previous - count);
    if (previous == next) return;
    if (next == 0) tags.erase(tag.GetKey());
    else tags[tag.GetKey()] = next;
    pendingEvents.push_back({tag, static_cast<float>(previous), static_cast<float>(next), EEventType::Tag});
    tagsDirty = true;
}

bool EHAbilitySystemComponent::ValidateEffect(const EHEffect& effect) const {
    if (effect.type == EEffectType::Duration && effect.durationFrames <= 0) return false;
    if (effect.type == EEffectType::Instant && !effect.tags.empty()) return false;
    for (const auto& modifier : effect.modifiers) {
        if (!attributes.contains(modifier.attribute.GetKey()) || !std::isfinite(modifier.value) ||
            (modifier.type == EAttributeModifierType::Divide && modifier.value == 0.f)) return false;
    }
    for (const auto& tag : effect.tags) if (tag.tag.GetKey().empty() || tag.count <= 0) return false;
    return true;
}

const EHEffect* EHAbilitySystemComponent::LoadEffectDefinition(const FName& effectAsset) {
    const auto cached = effectDefinitions.find(effectAsset.GetKey());
    if (cached != effectDefinitions.end()) return &cached->second;
    json data;
    if (!EHGameInstance::LoadAssetAsJson(effectAsset, data)) return nullptr;
    try {
        auto [entry, inserted] = effectDefinitions.emplace(effectAsset.GetKey(), data.get<EHEffect>());
        return &entry->second;
    } catch (const std::exception& error) {
        std::cerr << "LoadEffectDefinition " << effectAsset.GetKey() << ": " << error.what() << '\n';
        return nullptr;
    }
}

FEffectHandle EHAbilitySystemComponent::ApplyEffect(const FName& effectAsset, EHActor* source) {
    const EHEffect* definition = LoadEffectDefinition(effectAsset);
    return definition ? ApplyEffect(*definition, source) : FEffectHandle{};
}

FEffectHandle EHAbilitySystemComponent::ApplyEffect(const EHEffect& definition, EHActor* source) {
    FOperation operation(*this);
    if (shuttingDown || !ValidateEffect(definition)) return {};
    const FEffectHandle handle = NextEffectHandle();
    if (definition.type == EEffectType::Instant) {
        auto modifiers = definition.modifiers;
        std::stable_sort(modifiers.begin(), modifiers.end(), [](const auto& a, const auto& b) { return a.type < b.type; });
        for (const auto& modifier : modifiers) {
            auto& attribute = attributes.at(modifier.attribute.GetKey());
            attribute.baseValue = Modify(attribute.baseValue, modifier);
        }
    } else {
        effects.emplace(handle.id, FActiveEffect{handle, definition, definition.durationFrames, source});
        for (const auto& grant : definition.tags) AddTag(grant.tag, grant.count);
    }
    RecalculateAttributes();
    return handle;
}

bool EHAbilitySystemComponent::RemoveEffect(FEffectHandle handle) {
    FOperation operation(*this);
    const auto found = effects.find(handle.id);
    if (found == effects.end()) return false;
    const auto grants = found->second.definition.tags;
    effects.erase(found);
    for (const auto& grant : grants) RemoveTag(grant.tag, grant.count);
    RecalculateAttributes();
    return true;
}

void EHAbilitySystemComponent::RecalculateAttributes() {
    std::vector<FAttributeModifier> modifiers;
    for (const auto& [id, effect] : effects)
        modifiers.insert(modifiers.end(), effect.definition.modifiers.begin(), effect.definition.modifiers.end());
    std::stable_sort(modifiers.begin(), modifiers.end(), [](const auto& a, const auto& b) { return a.type < b.type; });
    std::map<std::string, float> calculated;
    std::function<float(const std::string&)> calculate = [&](const std::string& name) {
        if (calculated.contains(name)) return calculated.at(name);
        auto& attribute = attributes.at(name);
        attribute.baseValue = ClampAttribute(attribute.baseValue, attribute);
        std::optional<float> upperBound;
        if (!attribute.maxAttribute.GetKey().empty()) {
            upperBound = calculate(attribute.maxAttribute.GetKey());
            if (attribute.minimum) upperBound = std::max(*upperBound, *attribute.minimum);
            attribute.baseValue = std::min(attribute.baseValue, *upperBound);
        }
        float value = attribute.baseValue;
        for (const auto& modifier : modifiers) if (modifier.attribute.GetKey() == name) value = Modify(value, modifier);
        value = ClampAttribute(value, attribute);
        if (upperBound) value = std::min(value, *upperBound);
        calculated[name] = value;
        return value;
    };
    for (auto& [name, attribute] : attributes) {
        const float previous = attribute.value;
        attribute.value = calculate(name);
        if (previous != attribute.value) pendingEvents.push_back({FName(name), previous, attribute.value, EEventType::Attribute});
    }
}

void EHAbilitySystemComponent::FlushChanges() {
    if (flushing) return;
    flushing = true;
    ++operationDepth;
    for (;;) {
        bool removed = false;
        for (auto it = abilities.begin(); it != abilities.end();) {
            if (!it->second->pendingRemoval) { ++it; continue; }
            auto ability = std::move(it->second);
            it = abilities.erase(it);
            ability->Uninitialize();
            removed = true;
        }
        if (tagsDirty && !shuttingDown) {
            tagsDirty = false;
            std::vector<FName> names;
            for (const auto& [name, ability] : abilities) names.emplace_back(name);
            for (const auto& name : names) {
                EHAbility* ability = GetAbility(name);
                if (!ability) continue;
                const bool allowed = !HasAnyTags(ability->blockedTags) && HasAllTags(ability->requiredTags);
                const bool activationMet = HasAllTags(ability->activationTags);
                if (ability->active && (!allowed || !activationMet)) ability->End();
                else if (!ability->active && allowed && activationMet && !ability->activationTags.empty()) ability->Activate();
            }
        }
        auto events = std::move(pendingEvents);
        pendingEvents.clear();
        if (!shuttingDown) for (const auto& event : events) {
            if (event.type == EEventType::Attribute) OnAttributeChanged.Invoke(event.name, event.oldValue, event.newValue);
            else if (event.type == EEventType::Tag) OnTagChanged.Invoke(event.name, static_cast<int>(event.newValue));
            else OnAbilityActiveChanged.Invoke(event.name, event.newValue != 0.f);
        }
        const bool pendingRemoval = std::ranges::any_of(abilities, [](const auto& entry) { return entry.second->pendingRemoval; });
        if (!removed && !pendingRemoval && pendingEvents.empty() && (!tagsDirty || shuttingDown)) break;
    }
    --operationDepth;
    flushing = false;
}
