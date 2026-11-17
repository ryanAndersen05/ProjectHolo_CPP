#include "gameplayability/EHAbilitySystemComponent.h"
#include "core/EHGameInstance.h"
#include "factory/EHActorComponentFactory.h"
#include <cmath>
#include <iostream>
#include <stdexcept>

namespace {
    const FName Health("health"), Speed("speed"), Ticks("ticks"), Attacking("attacking"), Stunned("stunned");
    void Check(bool condition, const char* message) { if (!condition) throw std::runtime_error(message); }
    void Near(std::optional<float> actual, float expected) {
        Check(actual && std::abs(*actual - expected) < 0.0001f, "Unexpected attribute value");
    }
    EHAbilitySystemComponent& Attach(EHActor& actor, std::vector<std::string> abilities = {}) {
        json data = {
            {"attributes", {
                {"maxHealth", {{"base",100}, {"min",0}}},
                {"health", {{"base",100}, {"min",0}, {"maxAttribute","maxHealth"}}},
                {"speed", {{"base",10}, {"min",0}}},
                {"ticks", {{"base",0}}}
            }}, {"abilities", abilities}
        };
        actor.InitializeActor(json::array({{{"componentType","abilitysystem"}, {"componentName","abilitysystem"}, {"data",data}}}));
        auto* component = dynamic_cast<EHAbilitySystemComponent*>(actor.GetActorComponent(EHActorComponentFactory::AbilitySystemComponentId));
        Check(component, "Ability component factory failed");
        return *component;
    }
    EHEffect Modifier(const FName& attribute, EAttributeModifierType type, float value, EEffectType lifetime) {
        EHEffect effect;
        effect.type = lifetime;
        effect.modifiers.push_back({attribute,type,value});
        return effect;
    }
    void TestAttributesAndEffects() {
        EHActor first, second;
        auto& system = Attach(first);
        auto& other = Attach(second);
        Check(!system.GetAttribute(FName("unknown")), "Missing attribute silently became zero");
        int notifications = 0;
        system.OnAttributeChanged.AddListener([&](FName name, float oldValue, float newValue) {
            if (name == Health) { ++notifications; Check(oldValue != newValue, "Redundant attribute event"); }
        });
        auto buff = system.ApplyEffect(Modifier(Speed,EAttributeModifierType::Multiply,2,EEffectType::Infinite));
        Near(system.GetAttribute(Speed),20);
        auto instant = system.ApplyEffect(Modifier(Speed,EAttributeModifierType::Add,5,EEffectType::Instant));
        Check(instant.IsValid() && !system.HasEffect(instant), "Instant application was retained");
        Near(system.GetBaseAttribute(Speed),15);
        Near(system.GetAttribute(Speed),30);
        Check(!other.RemoveEffect(buff), "Effect handle affected a different actor");
        Check(system.RemoveEffect(buff) && !system.RemoveEffect(buff), "Effect removal was not one-shot");
        Near(system.GetAttribute(Speed),15);
        system.ApplyEffect(FName("effect_basic_damage"), &second);
        Near(system.GetAttribute(Health),75);
        Near(other.GetAttribute(Health),100);
        system.SetBaseAttribute(Health,10000);
        Near(system.GetBaseAttribute(Health),100);
        system.ApplyEffect(FName("effect_basic_damage"));
        Near(system.GetAttribute(Health),75); // Overhealing did not leave a hidden health reserve.
        system.SetBaseAttribute(Health,-100);
        Near(system.GetAttribute(Health),0);
        Check(notifications == 4, "Attribute changes were not notified correctly");
        system.SetBaseAttribute(Health,100);
        auto cap = system.ApplyEffect(Modifier(FName("maxHealth"),EAttributeModifierType::Multiply,0.5f,EEffectType::Infinite));
        Near(system.GetAttribute(Health),50);
        Near(system.GetBaseAttribute(Health),50);
        system.RemoveEffect(cap);
        Near(system.GetAttribute(Health),50);
        system.SetBaseAttribute(Health,0);

        EHEffect invalid = Modifier(Health,EAttributeModifierType::Add,10,EEffectType::Infinite);
        invalid.modifiers.push_back({FName("missing"),EAttributeModifierType::Add,1});
        invalid.tags.push_back({FName("invalid"),1});
        Check(!system.ApplyEffect(invalid).IsValid(), "Invalid effect partially applied");
        Near(system.GetAttribute(Health),0);
        Check(!system.HasTag(FName("invalid")), "Rejected effect leaked tags");
        EHEffect divide = Modifier(Speed,EAttributeModifierType::Divide,0,EEffectType::Instant);
        Check(!system.ApplyEffect(divide).IsValid(), "Zero divisor accepted");

        EHEffect tagged;
        tagged.type = EEffectType::Duration;
        tagged.durationFrames = 2;
        tagged.tags.push_back({FName("invulnerable"),1});
        auto one = system.ApplyEffect(tagged);
        auto two = system.ApplyEffect(tagged);
        Check(system.GetTagCount(FName("invulnerable")) == 2, "Tag sources were not counted");
        system.RemoveEffect(one);
        Check(system.GetTagCount(FName("invulnerable")) == 1, "Removing one source cleared the other tag");
        system.Tick(0);
        system.Tick(1.f/60.f);
        Check(system.HasEffect(two), "Duration effect expired too early");
        system.Tick(1.f/60.f);
        Check(!system.HasEffect(two) && !system.HasTag(FName("invulnerable")), "Duration effect failed to clean up");
    }
    void TestLuaAndIsolation() {
        EHActor first, second;
        auto& system = Attach(first,{"ability_basic_damage","ability_guard","counter"});
        auto& other = Attach(second,{"ability_guard","counter"});
        Check(!system.ActivateAbility(FName("ability_basic_damage")), "Damage accepted a missing target");
        Check(other.ActivateAbility(FName("ability_guard")), "Lua guard failed");
        Check(!system.ActivateAbility(FName("ability_basic_damage"),&second), "Guard did not block damage");
        for (int i=0;i<12;++i) other.Tick(1.f/60.f);
        Check(!other.HasTag(FName("invulnerable")), "Guard did not end");
        Check(system.ActivateAbility(FName("ability_basic_damage"),&second), "Lua damage activation failed");
        Near(other.GetAttribute(Health),75);
        Check(!system.GetAbility(FName("ability_basic_damage"))->GetIsActive(), "Instant ability did not end itself");
        Check(!system.ActivateAbility(FName("counter")), "Required activation tag was ignored");
        system.AddTag(FName("ready")); other.AddTag(FName("ready"));
        Check(system.ActivateAbility(FName("counter")) && other.ActivateAbility(FName("counter")), "Counter activation failed");
        Check(!system.ActivateAbility(FName("counter")), "Active ability activated twice");
        system.Tick(1.f/60.f); system.Tick(1.f/60.f); other.Tick(1.f/60.f);
        Near(system.GetAttribute(Ticks),2); Near(other.GetAttribute(Ticks),1);
        system.Tick(1.f/60.f);
        Check(!system.HasTag(Attacking) && other.HasTag(Attacking), "Lua state leaked between owners");
        Near(system.GetAttribute(Speed),10); Near(other.GetAttribute(Speed),20);
        other.AddTag(Stunned);
        Check(!other.GetAbility(FName("counter"))->GetIsActive(), "Blocking tag did not cancel active ability");
        Near(other.GetAttribute(Speed),10);
        Check(!other.HasTag(Attacking), "Cancellation leaked owned tags");
        Check(!system.GrantAbility(FName("invalid_script_ability")), "Non-table Lua script accepted");
        Check(!system.GetAbility(FName("invalid_script_ability")), "Failed grant was retained");
    }
    void TestCallbacksAndRemoval(EHGameInstance& instance) {
        EHActor actor;
        auto& system = Attach(actor,{"counter_remove","counter_auto","counter_error","counter_begin_error"});
        Check(!system.ActivateAbility(FName("counter_begin_error")), "Failed begin returned success");
        Check(!system.HasTag(Attacking), "Failed begin leaked owned tags");
        Near(system.GetAttribute(Speed),10);
        system.AddTag(FName("auto"));
        Check(system.GetAbility(FName("counter_auto"))->GetIsActive(), "Activation tags did not start ability");
        system.RemoveTag(FName("auto"));
        Check(!system.HasTag(Attacking), "Lost activation tags did not end ability");
        Check(system.ActivateAbility(FName("counter_remove")), "Remove-on-end activation failed");
        system.Tick(1.f/60.f);
        Check(!system.GetAbility(FName("counter_remove")), "Ability was not removed after its own tick");
        Near(system.GetAttribute(Speed),10);
        Check(system.ActivateAbility(FName("counter_error")), "Failure test did not activate");
        system.Tick(1.f/60.f);
        Check(!system.HasTag(Attacking), "Script failure leaked activation tags");
        Near(system.GetAttribute(Speed),10);

        std::uint32_t listener = 0;
        listener = system.OnAttributeChanged.AddListener([&](FName name,float,float) {
            if (name == Health) {
                system.RemoveAbility(FName("counter_error"));
                system.OnAttributeChanged.RemoveListener(listener);
                system.AddTag(FName("callback"));
            }
        });
        system.SetBaseAttribute(Health,90);
        Check(!system.GetAbility(FName("counter_error")) && system.HasTag(FName("callback")), "Reentrant callback changes were lost");
        auto table = instance.GetLuaScriptSystem()->GetTable(FName("counter_script"));
        const int before = table.get<int>("uninitialized");
        {
            EHActor temporary;
            auto& component = Attach(temporary,{"counter"});
            component.AddTag(FName("ready"));
            component.ActivateAbility(FName("counter"));
        }
        Check(table.get<int>("uninitialized") == before+1, "Actor cleanup did not uninitialize abilities");
    }
    void TestGameModeCleanup(EHGameInstance& instance) {
        instance.InitializeGame({FName("ability_mode"),FName{}});
        EHActor* first = instance.GetGameMode()->CreateActor(FName("ability_actor"));
        EHActor* second = instance.GetGameMode()->CreateActor(FName("ability_actor"));
        auto* one = dynamic_cast<EHAbilitySystemComponent*>(first->GetActorComponent(EHActorComponentFactory::AbilitySystemComponentId));
        auto* two = dynamic_cast<EHAbilitySystemComponent*>(second->GetActorComponent(EHActorComponentFactory::AbilitySystemComponentId));
        one->AddTag(FName("ready")); two->AddTag(FName("ready"));
        one->ActivateAbility(FName("counter"),second); two->ActivateAbility(FName("counter"),first);
        auto table = instance.GetLuaScriptSystem()->GetTable(FName("counter_script"));
        const int before = table.get<int>("uninitialized");
        instance.InitializeGame({FName("ability_mode"),FName{}});
        Check(table.get<int>("uninitialized") == before+2, "Mode cleanup failed while Lua/targets were still alive");
    }
}
int main() {
    try {
        EHGameInstance instance;
        TestAttributesAndEffects();
        TestLuaAndIsolation();
        TestCallbacksAndRemoval(instance);
        TestGameModeCleanup(instance);
        std::cout << "Ability system checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
