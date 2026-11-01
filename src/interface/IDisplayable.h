#pragma once
#include "render/EHRenderQueue.h"

class IDisplayable {
public:
    virtual ~IDisplayable() = default;
    virtual void CollectDrawCommands(FRenderQueue& queue, const FRenderContext& context) const = 0;
};
