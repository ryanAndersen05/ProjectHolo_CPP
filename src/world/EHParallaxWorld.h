#pragma once
#include "interface/ILateTickable.h"
#include "core/EHActor.h"
#include "library/EHLibrary.h"
#include <vector>

struct FBackgroundLayer {
public:
    float parallaxEffectStrength;
    int spriteLength;
    FName componentName;
    FVector offset;

    FBackgroundLayer() : parallaxEffectStrength(1.0f), spriteLength(480), componentName(FName()), offset(FVector::Zero) {}
    NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FBackgroundLayer, parallaxEffectStrength, spriteLength, componentName, offset)
};

class EHParallaxWorld : public EHActor, public ILateTickable {
private:
    std::vector<FBackgroundLayer> backgroundLayers;

public:
    void LateTick(float deltaTime) override;
};