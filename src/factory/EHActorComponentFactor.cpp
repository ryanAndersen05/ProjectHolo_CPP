#include "EHActorComponentFactor.h"
#include "sprite/EHSpriteComponent.h"

const FName EHActorComponentFactory::SpriteComponentId = FName("sprite");

EHActorComponent* EHActorComponentFactory::CreateActorComponent(const FName &actorId) {
    if (actorId == SpriteComponentId) return new EHSpriteComponent();

    return nullptr;
}
