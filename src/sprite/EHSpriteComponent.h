#pragma once
#include "core/EHActorComponent.h"
#include "EHSpriteManager.h"
#include "interface/IDisplayable.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

struct FMaterial {
    FName vertAsset;
    FName fragAsset;

    FMaterial() = default;
};

NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FMaterial, vertAsset, fragAsset);

class EHSpriteComponent : public EHActorComponent, public IDisplayable
{
private:
    FSpriteDrawData drawData;
    int drawOrder;
    FVector spriteOffset;
    FMaterial materialAsset;
    sf::Shader* shader;

public:
    EHSpriteComponent() : EHActorComponent(), drawData(FSpriteDrawData()), drawOrder(0), shader(nullptr) { }
    ~EHSpriteComponent() override;

    void InitializeComponent(EHActor *actr) override;
    void SetDrawData(const FName& drawName);
    void SetDrawData(const FSpriteDrawData& data) { drawData = data; }
    [[nodiscard]] const FSpriteDrawData& GetDrawData() const { return drawData; }
    void SetDrawOrder(const int order) { drawOrder = order; }
    [[nodiscard]] int GetDrawOrder() const { return drawOrder; }
    [[nodiscard]] sf::Shader* GetShader() const { return shader; }

    friend void from_json(const json& j, EHSpriteComponent& component);
    [[nodiscard]] FSpriteDisplayData GetSpriteDrawData() const override;
};