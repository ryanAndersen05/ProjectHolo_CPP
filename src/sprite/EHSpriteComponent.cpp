#include "EHSpriteComponent.h"
#include "core/EHGameInstance.h"
#include <iostream>

EHSpriteComponent::~EHSpriteComponent() {
    delete shader;
}

void EHSpriteComponent::InitializeComponent(EHActor *actr) {
    EHActorComponent::InitializeComponent(actr);
    std::string vertPath;
    std::string fragPath;
    if (!EHGameInstance::GetAssetPath(materialAsset.vertAsset, vertPath)) {
        std::cout << "InitializeComponent() - Invalid fragPath" << std::endl;
        return;
    }
    if (!EHGameInstance::GetAssetPath(materialAsset.fragAsset, fragPath)) {
        std::cout << "InitializeComponent() - Invalid fragPath" << std::endl;
        return;
    }
    shader = new sf::Shader();
    if (!shader->loadFromFile(fragPath, sf::Shader::Type::Fragment)) {
        std::cout << "InitializeComponent() - Failed to load shaders" << std::endl;
        delete shader;
        shader = nullptr;
    }
    SetColor(sf::Color::White);
    // shader->setUniform("_texture", sf::Shader::CurrentTexture);
}

void EHSpriteComponent::SetDrawData(const FName& drawName) {
    EHSpriteManager* spriteManager = EHGameInstance::GetInstance()->GetSpriteManager();
    if (!spriteManager) {
        std::cout << "Failed to find Sprite Manager" << std::endl;
        return;
    }
    if (!spriteManager->GetSpriteDrawData(drawName, drawData)) {
        std::cout << "Failed to find Sprite with id: " << drawName.GetKey() << std::endl;
    }
}

void EHSpriteComponent::SetColor(const sf::Color &col) {
    color = col;
    sf::Glsl::Vec4 vecCol = color;
    if (shader) shader->setUniform("_color", vecCol);
}

void from_json(const json& j, EHSpriteComponent& component) {
    FName spriteId = j.at("defaultSprite").get<FName>();
    j.at("spriteOffset").get_to(component.spriteOffset);
    j.at("materialAsset").get_to(component.materialAsset);

    if (spriteId.isValid()) {
        component.SetDrawData(spriteId);
    }
}

FSpriteDisplayData EHSpriteComponent::GetSpriteDrawData() const {
    FVector spritePosition = spriteOffset + GetActorPosition();
    FSpriteDisplayData spriteDisplayData(drawData, shader, drawOrder, spritePosition, GetActorScale(), GetActorRotation());
    return spriteDisplayData;
}
