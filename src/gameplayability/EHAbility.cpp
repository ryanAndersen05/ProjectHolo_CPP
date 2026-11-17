//
// Created by ryana on 11/4/2026.
//

#include "EHAbility.h"
#include "EHAbilitySystemComponent.h"
#include "core/EHGameInstance.h"

namespace {
    sol::object JsonToLua(sol::state_view lua, const json& value) {
        if (value.is_object() || value.is_array()) {
            sol::table table = lua.create_table();
            if (value.is_object()) {
                for (auto it = value.begin(); it != value.end(); ++it) table[it.key()] = JsonToLua(lua, it.value());
            } else {
                for (std::size_t i = 0; i < value.size(); ++i) table[i + 1] = JsonToLua(lua, value[i]);
            }
            return sol::make_object(lua, table);
        }
        if (value.is_boolean()) return sol::make_object(lua, value.get<bool>());
        if (value.is_number()) return sol::make_object(lua, value.get<double>());
        if (value.is_string()) return sol::make_object(lua, value.get<std::string>());
        return sol::make_object(lua, sol::nil);
    }
    bool ReportResult(const sol::protected_function_result& result, const FName& id, const char* callback) {
        if (result.valid()) return true;
        sol::error error = result;
        std::cerr << "Ability " << id.GetKey() << " " << callback << ": " << error.what() << '\n';
        return false;
    }
}

bool EHAbility::Initialize(EHAbilitySystemComponent& owner, const FName& abilityId, const json& definition) {
    system = &owner;
    id = abilityId;
    requiredTags = definition.value("requiredTags", std::vector<FName>{});
    blockedTags = definition.value("blockedTags", std::vector<FName>{});
    activationTags = definition.value("activationTags", std::vector<FName>{});
    ownedTags = definition.value("ownedTags", std::vector<FGameplayTagGrant>{});
    effectsOnBegin = definition.value("effectsOnBegin", std::vector<FName>{});
    removeOnEnd = definition.value("removeOnEnd", false);
    scriptAsset = definition.at("scriptAsset").get<FName>();
    auto* scripting = EHGameInstance::GetInstance()->GetLuaScriptSystem();
    scripting->LoadTable(scriptAsset);
    sol::optional<sol::table> loaded = scripting->GetTable(scriptAsset);
    if (!loaded || !loaded->valid()) return false;
    script = *loaded;
    sol::state_view lua(script.lua_state());
    runtime = lua.create_table();
    runtime["config"] = JsonToLua(lua, definition.value("config", json::object()));
    sol::protected_function initialize = script["onInitialize"];
    if (initialize.valid()) {
        auto result = initialize(runtime, this);
        return ReportResult(result, id, "onInitialize");
    }
    return true;
}

void EHAbility::Uninitialize() {
    Call("onUninitialize");
    const bool wasLoaded = script.valid();
    runtime = sol::table{};
    script = sol::table{};
    if (wasLoaded) EHGameInstance::GetInstance()->GetLuaScriptSystem()->UnloadTable(scriptAsset);
}

EHActor* EHAbility::GetActor() const { return system->GetActor(); }

bool EHAbility::CanActivate(EHActor* abilityTarget) const {
    EHAbilitySystemComponent::FOperation operation(*system);
    if (active || ending || pendingRemoval || system->shuttingDown ||
        !system->HasAllTags(requiredTags) || system->HasAnyTags(blockedTags)) return false;
    sol::protected_function check = script["canActivate"];
    if (!check.valid()) return true;
    auto result = check(runtime, const_cast<EHAbility*>(this), abilityTarget);
    return ReportResult(result, id, "canActivate") && result.get_type() == sol::type::boolean && result.get<bool>() &&
        !pendingRemoval && !active && !system->shuttingDown &&
        system->HasAllTags(requiredTags) && !system->HasAnyTags(blockedTags);
}

bool EHAbility::Activate(EHActor* abilityTarget) {
    EHAbilitySystemComponent::FOperation operation(*system);
    if (!CanActivate(abilityTarget)) return false;
    // Resolve all startup effects before changing gameplay state.
    std::vector<EHEffect> definitions;
    for (const FName& asset : effectsOnBegin) {
        const EHEffect* effect = system->LoadEffectDefinition(asset);
        if (!effect || !system->ValidateEffect(*effect)) return false;
        definitions.push_back(*effect);
    }
    target = abilityTarget;
    active = true;
    system->pendingEvents.push_back({id, 0.f, 1.f, EHAbilitySystemComponent::EEventType::Ability});
    for (const auto& grant : ownedTags) system->AddTag(grant.tag, grant.count);
    for (const auto& definition : definitions) {
        FEffectHandle handle = system->ApplyEffect(definition, GetActor());
        if (system->HasEffect(handle)) ownedEffects.push_back(handle);
    }
    return Call("onBegin");
}

void EHAbility::End() {
    EHAbilitySystemComponent::FOperation operation(*system);
    if (!active || ending) return;
    active = false;
    ending = true;
    system->pendingEvents.push_back({id, 1.f, 0.f, EHAbilitySystemComponent::EEventType::Ability});
    Call("onEnd");
    for (const auto& handle : ownedEffects) system->RemoveEffect(handle);
    ownedEffects.clear();
    for (const auto& grant : ownedTags) system->RemoveTag(grant.tag, grant.count);
    target = nullptr;
    ending = false;
    if (removeOnEnd) pendingRemoval = true;
}

bool EHAbility::Call(const char* callback) {
    if (!script.valid()) return true;
    sol::protected_function function = script[callback];
    if (!function.valid()) return true;
    auto result = function(runtime, this);
    const bool succeeded = ReportResult(result, id, callback);
    if (!succeeded && active) End();
    return succeeded;
}

void EHAbility::Tick(float deltaTime) {
    if (!active || pendingRemoval) return;
    sol::protected_function tick = script["onTick"];
    if (!tick.valid()) return;
    auto result = tick(runtime, this, deltaTime);
    if (!ReportResult(result, id, "onTick")) End();
}
