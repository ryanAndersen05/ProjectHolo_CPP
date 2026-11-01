#include "EHCamera.h"
#include <algorithm>
#include "core/EHGameInstance.h"
#include "library/EHGameData.h"

EHCamera* EHCamera::MainCamera = nullptr;

EHCamera::EHCamera() : EHActorComponent(), cameraSize(8.5f) {
    MainCamera = this;
}

EHCamera::~EHCamera() {
    if (MainCamera == this) MainCamera = nullptr;
}

void EHCamera::DrawGame(sf::RenderWindow &window, const FRenderQueue& displayables) const {
    float horizontalOffset = cameraSize * 0.5f ;
    float verticalOffset = (cameraSize * 9.f / 16.f) * 0.5f;
    FVector offsetPosition = -(offset + GetActorPosition()) + FVector(horizontalOffset, verticalOffset);
    offsetPosition = offsetPosition * EHGameInstance::GetPixelToUnitConversion();

    float pixelScale = EHUserSettings::ScreenWidth / (EHGameInstance::GetPixelToUnitConversion() * cameraSize);

    // Sort pointers so the collected queue remains unchanged and ties retain submission order.
    std::vector<const FSpriteDisplayData*> ordered;
    ordered.reserve(displayables.sprites.size());
    for (const auto& command : displayables.sprites) ordered.push_back(&command);
    std::stable_sort(ordered.begin(), ordered.end(), [](const auto* first, const auto* second) {
        return first->drawOrder < second->drawOrder;
    });

    for (const FSpriteDisplayData* command : ordered) {
        const auto& data = *command;
        const FSpriteDrawData& drawData = data.drawData;
        if (!drawData.IsValid()) continue;
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
        spriteScale = FVector(spriteScale.x * data.scale.x, spriteScale.y * data.scale.y);
        sprite.setScale({spriteScale.x, spriteScale.y});
        window.draw(sprite, data.shader);
    }

    for (const FRectangleDrawCommand& rectangle : displayables.debugRectangles) {
        const FVector minimum = rectangle.bounds.GetPosition();
        const FVector size = rectangle.bounds.GetSize();
        const float unitsToScreen = EHGameInstance::GetPixelToUnitConversion() * pixelScale;
        const FVector topLeft(minimum.x, -(minimum.y + size.y));
        const FVector screenPosition = (topLeft * EHGameInstance::GetPixelToUnitConversion() + offsetPosition) * pixelScale;
        sf::RectangleShape shape({size.x * unitsToScreen, size.y * unitsToScreen});
        shape.setPosition({screenPosition.x, screenPosition.y});
        shape.setFillColor(rectangle.fillColor);
        shape.setOutlineColor(rectangle.outlineColor);
        shape.setOutlineThickness(-1.f); // One screen pixel, inside the collision bounds.
        window.draw(shape);
    }
}
