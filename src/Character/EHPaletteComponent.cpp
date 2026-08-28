#include "EHPaletteComponent.h"
#include "core/EHGameInstance.h"
#include <sfml/Graphics.hpp>
#include "sprite/EHSpriteComponent.h"

void EHPaletteComponent::ApplyColorPalette(const FName &characterId, int colorPaletteIndex) {
    EHGameInstance* instance = EHGameInstance::GetInstance();
    EHDataTableManager* dataTableManager = instance->GetDataTableManager();
    if (!dataTableManager) {
        std::cout << "ApplyColorPalette() - Invalid DataTableManager" << std::endl;
        return;
    }
    EHCharacterTableRow characterData;
    if (!dataTableManager->GetCharacterDataById(characterId, characterData)) {
        std::cout << "ApplyColorPalette() - Unable to find character data for rowId: " << characterId.GetKey() << std::endl;
        return;
    }
    std::vector<FName>& colorPalettes = characterData.GetColorPalettes();
    if (colorPaletteIndex < 0 || colorPaletteIndex >= static_cast<int>(colorPalettes.size())) {
        std::cout << "ApplyColorPalette() - Color Index is out of range" << std::endl;
        return;
    }
    std::string pathToLoad;
    std::string defaultPath;
    if (!EHGameInstance::GetAssetPath(colorPalettes[colorPaletteIndex], pathToLoad)) {
        return;
    }
    if (!EHGameInstance::GetAssetPath(colorPalettes[0], defaultPath)) {
        return;
    }
    sf::Image defaultColorPalette;
    sf::Image colorPaletteTexture;
    if (!defaultColorPalette.loadFromFile(defaultPath)) {
        return;
    }
    if (!colorPaletteTexture.loadFromFile(pathToLoad)) {
        std::cerr << "Failed to load color palette from " << pathToLoad << std::endl;
        return;
    }
    auto [width, height] = colorPaletteTexture.getSize();
    std::vector<std::uint8_t> pixels(PaletteSize * PaletteSize * 4, 0);
    for (unsigned i = 0; i < width; i++) {
        for (unsigned j = 0; j < height; j++) {
            sf::Color defColor = defaultColorPalette.getPixel({i, j});
            sf::Color col = colorPaletteTexture.getPixel({i, j});
            if (col.a == 0) continue;

            unsigned int index = (PaletteSize * defColor.g + defColor.r) * 4;
            pixels[index + 0] = col.r;
            pixels[index + 1] = col.g;
            pixels[index + 2] = col.b;
            pixels[index + 3] = col.a;
        }
    }

    paletteTexture.update(pixels.data());
    EHSpriteComponent* spriteComponent = dynamic_cast<EHSpriteComponent*>(GetComponentById(FName("sprite")));
    sf::Shader* shader = spriteComponent->GetShader();
    shader->setUniform("_swapTexture", paletteTexture);
}
