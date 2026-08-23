#pragma once
#include "EHActor.h"

class EHActorComponent
{
private:
    EHActor* actor;

public:
    EHActorComponent() : actor(nullptr) {}
    virtual ~EHActorComponent() = default;
    virtual void InitializeComponent(EHActor* actr);
    EHActor* GetActor() const {return actor;}

    void SetActorPosition(FVector position) const {actor->SetPosition(position);}
    void SetActorRotation(float rotation) const {actor->SetRotation(rotation);}
    void SetActorScale(FVector scale) const {actor->SetScale(scale);}

    [[nodiscard]] FVector GetActorPosition() const {return actor->GetPosition();}
    [[nodiscard]] float GetActorRotation() const {return actor->GetRotation();}
    [[nodiscard]] FVector GetActorScale() const {return actor->GetScale();}
};