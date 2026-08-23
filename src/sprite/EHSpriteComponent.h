#pragma once
#include "core/EHActorComponent.h"
#include "EHSpriteManager.h"
#include "interface/IDisplayable.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

class EHSpriteComponent : public EHActorComponent, public IDisplayable
{
private:
    FSpriteDrawData drawData;
    int drawOrder;

public:
    EHSpriteComponent() : EHActorComponent(), drawData(FSpriteDrawData()), drawOrder(0) { }

    void SetDrawData(const FName& drawName);
    void SetDrawData(const FSpriteDrawData& data) { drawData = data; }
    [[nodiscard]] const FSpriteDrawData& GetDrawData() const { return drawData; }
    void SetDrawOrder(const int order) { drawOrder = order; }
    [[nodiscard]] int GetDrawOrder() const { return drawOrder; }

    friend void from_json(const json& j, EHSpriteComponent& component);
    [[nodiscard]] FSpriteDisplayData GetSpriteDrawData() const override;
};