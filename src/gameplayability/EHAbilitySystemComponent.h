#include "core/EHActorComponent.h"
#include "EHAbility.h"
#include <map>
#include <memory>
#include <optional>

struct FAttributeValue {
    float baseValue = 0.f;
    float value = 0.f;
    std::optional<float> minimum;
    std::optional<float> maximum;
    FName maxAttribute;
};

class EHAbilitySystemComponent : public EHActorComponent, public ITickable {
    friend class EHAbility;
private:
    enum class EEventType {
        Attribute,
        Tag,
        Ability
    };

    struct FActiveEffect {
        FEffectHandle handle;
        EHEffect definition;
        int remainingFrames;
        EHActor* source;
    };

    struct FPendingEvent {
        FName name;
        float oldValue;
        float newValue;
        EEventType type;
    };

    std::map<std::string, FAttributeValue> attributes;
    std::map<std::string, std::unique_ptr<EHAbility>> abilities;
    std::map<std::uint64_t, FActiveEffect> effects;
    std::map<std::string, EHEffect> effectDefinitions;
    std::map<std::string, int> tags;
    std::vector<FName> defaultAbilities;
    std::vector<FPendingEvent> pendingEvents;
    int operationDepth = 0;
    bool flushing = false;
    bool shuttingDown = false;
    bool tagsDirty = false;

    struct FOperation {
        EHAbilitySystemComponent& system;
        explicit FOperation(EHAbilitySystemComponent& owner) : system(owner) { ++system.operationDepth; }
        ~FOperation() { if (--system.operationDepth == 0) system.FlushChanges(); }
    };
    void FlushChanges();
    void RecalculateAttributes();
    [[nodiscard]] bool HasAllTags(const std::vector<FName>& names) const;
    [[nodiscard]] bool HasAnyTags(const std::vector<FName>& names) const;
    [[nodiscard]] bool ValidateEffect(const EHEffect& effect) const;
    const EHEffect* LoadEffectDefinition(const FName& effectAsset);

public:
    EHDelegate<FName, float, float> OnAttributeChanged;
    EHDelegate<FName, int> OnTagChanged;
    EHDelegate<FName, bool> OnAbilityActiveChanged;

    void InitializeComponent(EHActor* actor) override;
    void UninitializeComponent() override;
    void Tick(float deltaTime) override;

    bool GrantAbility(const FName& abilityId);
    bool RemoveAbility(const FName& abilityId);
    bool ActivateAbility(const FName& abilityId, EHActor* target = nullptr);
    bool EndAbility(const FName& abilityId);
    [[nodiscard]] EHAbility* GetAbility(const FName& abilityId) const;

    [[nodiscard]] std::optional<float> GetAttribute(const FName& name) const;
    [[nodiscard]] std::optional<float> GetBaseAttribute(const FName& name) const;
    bool SetBaseAttribute(const FName& name, float value);
    FEffectHandle ApplyEffect(const FName& effectAsset, EHActor* source = nullptr);
    FEffectHandle ApplyEffect(const EHEffect& definition, EHActor* source = nullptr);
    bool RemoveEffect(FEffectHandle handle);
    [[nodiscard]] bool HasEffect(FEffectHandle handle) const { return effects.contains(handle.id); }

    void AddTag(const FName& tag, int count = 1);
    void RemoveTag(const FName& tag, int count = 1);
    [[nodiscard]] int GetTagCount(const FName& tag) const;
    [[nodiscard]] bool HasTag(const FName& tag) const { return GetTagCount(tag) > 0; }

    friend void from_json(const json& data, EHAbilitySystemComponent& system);
};