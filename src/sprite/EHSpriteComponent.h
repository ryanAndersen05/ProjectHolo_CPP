#pragma once
#include "core/EHActorComponent.h"
#include "EHSpriteManager.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

class EHSpriteComponent : public EHActorComponent
{
private:
    FSpriteDrawData drawData;

public:
    EHSpriteComponent() : EHActorComponent(),  drawData(FSpriteDrawData()) {}
    void SetDrawData(const FName& drawName);
    void SetDrawData(const FSpriteDrawData& data) { drawData = data; }
    const FSpriteDrawData& GetDrawData() const { return drawData; }

    friend void from_json(const json& j, EHSpriteComponent& component);
};