#include "EHEffect.h"
#include "scripting/EHLuaScriptSystem.h"

class EHAbilitySystemComponent;
class EHActor;

class EHAbility {
    friend class EHAbilitySystemComponent;
private:
    FName id;
    FName scriptAsset;
    EHAbilitySystemComponent* system = nullptr;
    EHActor* target = nullptr;
    sol::table script;
    sol::table runtime;
    std::vector<FName> requiredTags;
    std::vector<FName> blockedTags;
    std::vector<FName> activationTags;
    std::vector<FGameplayTagGrant> ownedTags;
    std::vector<FName> effectsOnBegin;
    std::vector<FEffectHandle> ownedEffects;
    bool active = false;
    bool ending = false;
    bool pendingRemoval = false;
    bool removeOnEnd = false;

    bool Initialize(EHAbilitySystemComponent& owner, const FName& abilityId, const json& definition);
    void Uninitialize();
    bool Call(const char* callback);
    void Tick(float deltaTime);

public:
    [[nodiscard]] const FName& GetId() const { return id; }
    [[nodiscard]] bool GetIsActive() const { return active; }
    [[nodiscard]] EHAbilitySystemComponent* GetSystem() const { return system; }
    [[nodiscard]] EHActor* GetActor() const;
    [[nodiscard]] EHActor* GetTarget() const { return target; }
    bool CanActivate(EHActor* abilityTarget = nullptr) const;
    bool Activate(EHActor* abilityTarget = nullptr);
    void End();
};