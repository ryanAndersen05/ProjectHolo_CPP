#include "EHParallaxWorld.h"
#include "camera/EHCamera.h"
#include "core/EHGameInstance.h"
#include "sprite/EHSpriteComponent.h"
#include <cmath>
#include <stdexcept>
#include <unordered_set>

void EHParallaxWorld::InitializeActor(const json& componentJson) {
    if (spriteAsset.IsValid()) EHGameInstance::GetInstance()->GetSpriteManager()->LoadSpriteMetaData(spriteAsset);
    EHActor::InitializeActor(componentJson);
    for (auto& layer : backgroundLayers) {
        layer.spriteComponent = dynamic_cast<EHSpriteComponent*>(GetActorComponent(layer.componentName));
        if (!layer.spriteComponent) {
            throw std::invalid_argument("Background layer must reference a sprite component: " + layer.componentName.GetKey());
        }
    }
}

void EHParallaxWorld::DisplayActor(FRenderQueue& queue, const FRenderContext& context) const {
    const FVector cameraPosition = context.camera ? context.camera->GetViewPosition() : FVector::Zero;
    for (const auto& layer : backgroundLayers) {
        if (!layer.spriteComponent) continue;
        auto data = layer.spriteComponent->GetSpriteDrawData();
        // After ordinary camera translation, the layer moves at 1 / (1 + z).
        // Always derive from the authored position, never last frame's adjusted position.
        data.position = data.position + layer.offset + cameraPosition * (layer.z / (1.f + layer.z));
        queue.sprites.push_back(data);
    }
}

void from_json(const json& data, EHParallaxWorld& world) {
    const auto& definitions = data.at("backgroundLayers");
    if (!definitions.is_array()) throw std::invalid_argument("Background layers must be an array");
    std::vector<FBackgroundLayer> layers;
    std::unordered_set<FName> names;
    for (const auto& definition : definitions) {
        FBackgroundLayer layer;
        layer.componentName = definition.at("componentName").get<FName>();
        layer.z = definition.value("z", 0.f);
        layer.offset = definition.value("offset", FVector::Zero);
        if (!layer.componentName.IsValid() || !names.insert(layer.componentName).second
            || !std::isfinite(layer.z) || layer.z < 0.f
            || !std::isfinite(layer.offset.x) || !std::isfinite(layer.offset.y)) {
            throw std::invalid_argument("Invalid or duplicate background layer");
            }
        layers.push_back(layer);
    }
    const FName asset = data.value("spriteAsset", FName());
    world.backgroundLayers.swap(layers);
    world.spriteAsset = asset;
}
