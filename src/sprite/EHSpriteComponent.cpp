#include "EHSpriteComponent.h"
#include "core/EHGameInstance.h"
#include <iostream>

void EHSpriteComponent::SetDrawData(const FName& drawName) {
    EHSpriteManager* spriteManager = EHGameInstance::GetInstance()->GetSpriteManager();
    if (!spriteManager) {
        std::cout << "Failed to find Sprite Manager" << std::endl;
        return;
    }
    if (!spriteManager->GetSprteDrawData(drawName, drawData)) {
        std::cout << "Failed to find Sprite with id" << drawName.GetKey() << std::endl;
    }
}

void from_json(const json& j, EHSpriteComponent& component) {
    FName spriteId = j.at("defaultSprite").get<FName>();
    if (spriteId.isValid()) {
        component.SetDrawData(spriteId);
    }
}