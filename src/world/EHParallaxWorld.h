#pragma once
#include "core/EHActor.h"

class EHSpriteComponent;

struct FBackgroundLayer {
    FName componentName;
    float z = 0.f;
    FVector offset = FVector::Zero;
    EHSpriteComponent* spriteComponent = nullptr; // Resolved once during actor initialization.
};

class EHParallaxWorld : public EHActor {
private:
    std::vector<FBackgroundLayer> backgroundLayers;
    FName spriteAsset;
public:
    void InitializeActor(const json& componentJson) override;
    void DisplayActor(FRenderQueue& queue, const FRenderContext& context) const override;
    [[nodiscard]] const std::vector<FBackgroundLayer>& GetBackgroundLayers() const { return backgroundLayers; }
    friend void from_json(const json& data, EHParallaxWorld& world);
};