#include "EHAbilitySystemComponent.h"
#include "factory/EHActorComponentFactory.h"

void EHLuaScriptSystem::InitializeAbilityScripting() {
    lua.new_usertype<FEffectHandle>("EffectHandle", sol::no_constructor,
        "IsValid", &FEffectHandle::IsValid);
    lua.new_usertype<EHAbility>("Ability", sol::no_constructor,
        "Actor", &EHAbility::GetActor,
        "Target", &EHAbility::GetTarget,
        "System", &EHAbility::GetSystem,
        "IsActive", &EHAbility::GetIsActive,
        "End", &EHAbility::End,
        "Id", [](const EHAbility& ability) { return ability.GetId().GetKey(); });
    lua.new_usertype<EHAbilitySystemComponent>("AbilitySystemComponent", sol::no_constructor,
        "GrantAbility", [](EHAbilitySystemComponent& self, const std::string& id) { return self.GrantAbility(FName(id)); },
        "RemoveAbility", [](EHAbilitySystemComponent& self, const std::string& id) { return self.RemoveAbility(FName(id)); },
        "ActivateAbility", [](EHAbilitySystemComponent& self, const std::string& id, sol::optional<EHActor*> target) {
            return self.ActivateAbility(FName(id), target.value_or(nullptr));
        },
        "EndAbility", [](EHAbilitySystemComponent& self, const std::string& id) { return self.EndAbility(FName(id)); },
        "IsAbilityActive", [](EHAbilitySystemComponent& self, const std::string& id) {
            const EHAbility* ability = self.GetAbility(FName(id));
            return ability && ability->GetIsActive();
        },
        "GetAttribute", [](const EHAbilitySystemComponent& self, const std::string& name) -> sol::optional<float> {
            auto value = self.GetAttribute(FName(name));
            return value ? sol::optional<float>(*value) : sol::nullopt;
        },
        "SetBaseAttribute", [](EHAbilitySystemComponent& self, const std::string& name, float value) {
            return self.SetBaseAttribute(FName(name), value);
        },
        "ApplyEffect", [](EHAbilitySystemComponent& self, const std::string& asset, sol::optional<EHActor*> source) {
            return self.ApplyEffect(FName(asset), source.value_or(nullptr));
        },
        "RemoveEffect", &EHAbilitySystemComponent::RemoveEffect,
        "HasEffect", &EHAbilitySystemComponent::HasEffect,
        "AddTag", [](EHAbilitySystemComponent& self, const std::string& tag, sol::optional<int> count) {
            self.AddTag(FName(tag), count.value_or(1));
        },
        "RemoveTag", [](EHAbilitySystemComponent& self, const std::string& tag, sol::optional<int> count) {
            self.RemoveTag(FName(tag), count.value_or(1));
        },
        "HasTag", [](const EHAbilitySystemComponent& self, const std::string& tag) { return self.HasTag(FName(tag)); },
        "GetTagCount", [](const EHAbilitySystemComponent& self, const std::string& tag) { return self.GetTagCount(FName(tag)); });
}
