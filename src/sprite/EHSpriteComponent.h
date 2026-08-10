#pragma once
#include "core/EHActorComponent.h"
#include "EHSpriteManager.h"

class EHSpriteComponent : public EHActorComponent
{
private:
    FSpriteDrawData drawData;

public:
    EHSpriteComponent() : drawData(FSpriteDrawData()) {}
    void SetDrawData(const FSpriteDrawData& data) { drawData = data; }
    const FSpriteDrawData& GetDrawData() const { return drawData; }
};