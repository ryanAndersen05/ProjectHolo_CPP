#include "library/EHLibrary.h"
#include "core/EHActorComponent.h"

class EHActorComponentFactory {
    const static FName SpriteComponentId;
public:
    static EHActorComponent* CreateActorComponent(const FName& actorId);
};