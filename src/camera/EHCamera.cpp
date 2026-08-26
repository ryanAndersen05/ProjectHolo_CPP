#include "EHCamera.h"
#include "core/EHGameInstance.h"
#include "core/EHTime.h"
#include "library/EHGameData.h"

EHCamera* EHCamera::MainCamera = nullptr;

EHCamera::EHCamera() : EHActorComponent(), cameraSize(8.5f) {
    MainCamera = this;
}

EHCamera::~EHCamera() {
    if (MainCamera == this) MainCamera = nullptr;
}

void EHCamera::DrawGame(sf::RenderWindow &window, const std::vector<FSpriteDisplayData> &displayables) const {
    float horizontalOffset = cameraSize * 0.5f ;
    float verticalOffset = (cameraSize * 9.f / 16.f) * 0.5f;
    FVector offsetPosition = -(offset + GetActorPosition()) + FVector(horizontalOffset, verticalOffset);
    offsetPosition = offsetPosition * EHGameInstance::GetPixelToUnitConversion();

    float pixelScale = EHUserSettings::ScreenWidth / (EHGameInstance::GetPixelToUnitConversion() * cameraSize);

    for (const FSpriteDisplayData& data : displayables) {
        const FSpriteDrawData& drawData = data.drawData;
        const FSpriteData& spriteData = drawData.spriteData;
        FVector position = data.position;
        position = position * EHGameInstance::GetPixelToUnitConversion();
        position.y = -position.y;
        position = position - spriteData.pivot;
        position = position + offsetPosition;
        position = position * pixelScale;

        sf::Sprite sprite(*drawData.texture,
            sf::IntRect({spriteData.point.x, spriteData.point.y},{spriteData.size.x, spriteData.size.y}));
        sprite.setPosition({position.x, position.y});
        FVector spriteScale = FVector::One * pixelScale;
        sprite.setScale({spriteScale.x, spriteScale.y});
        window.draw(sprite);
    }
}
