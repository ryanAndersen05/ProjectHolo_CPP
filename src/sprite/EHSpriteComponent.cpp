#include "EHSpriteComponent.h"
#include "core/EHGameInstance.h"
#include <iostream>

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

void from_json(const json& j, EHSpriteComponent& component) {
    FName spriteId = j.at("defaultSprite").get<FName>();
    j.at("spriteOffset").get_to(component.spriteOffset);
    if (spriteId.isValid()) {
        component.SetDrawData(spriteId);
    }
}

FSpriteDisplayData EHSpriteComponent::GetSpriteDrawData() const {
    FVector spritePosition = spriteOffset + GetActorPosition();
    FSpriteDisplayData spriteDisplayData(drawData, drawOrder, spritePosition, GetActorScale(), GetActorRotation());
    return spriteDisplayData;
}
