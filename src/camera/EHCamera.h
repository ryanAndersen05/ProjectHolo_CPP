#pragma once
#include "core/EHActorComponent.h"


class EHCamera : public EHActorComponent {
public:
    static EHCamera* MainCamera;
private:
    FVector offset;
    float cameraSize;

public:
    EHCamera();
    ~EHCamera() override;

    void DrawGame(sf::RenderWindow& window, const std::vector<FSpriteDisplayData>& displayables) const;
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHCamera, offset, cameraSize);
};

