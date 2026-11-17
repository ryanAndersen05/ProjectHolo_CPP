#include "EHGameplayTag.h"
#include <vector>

enum class EEffectType {
    Instant,
    Duration,
    Infinite,
};
enum class EAttributeModifierType {
    Set,
    Add,
    Subtract,
    Multiply,
    Divide,
};

struct FAttributeModifier {
    FName attribute;
    EAttributeModifierType type = EAttributeModifierType::Add;
    float value = 0.f;
};

// Asset data; each application has its own handle and remaining frames.
class EHEffect {
public:
    EEffectType type = EEffectType::Instant;
    int durationFrames = 0;
    std::vector<FAttributeModifier> modifiers;
    std::vector<FGameplayTagGrant> tags;
};
void from_json(const json& data, EHEffect& effect);

struct FEffectHandle {
    std::uint64_t id = 0;
    [[nodiscard]] bool IsValid() const { return id != 0; }
    bool operator==(const FEffectHandle&) const = default;
};