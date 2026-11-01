#pragma once
#include "core/EHActorComponent.h"
#include "render/EHRenderQueue.h"


class EHCamera : public EHActorComponent {
public:
    static EHCamera* MainCamera;
private:
    FVector offset;
    float cameraSize;

public:
    EHCamera();
    ~EHCamera() override;

    void DrawGame(sf::RenderWindow& window, const FRenderQueue& displayables) const;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHCamera, offset, cameraSize);
};

