#pragma once
#include "core/EHActorComponent.h"
#include "library/EHLibrary.h"

class EHPaletteComponent : public EHActorComponent{
private:
    static int constexpr PaletteSize = 256;
    sf::Texture paletteTexture;
public:
    EHPaletteComponent() : EHActorComponent() { paletteTexture = sf::Texture({PaletteSize, PaletteSize}); }
    void ApplyColorPalette(const FName& characterId, int colorPaletteIndex);
};


