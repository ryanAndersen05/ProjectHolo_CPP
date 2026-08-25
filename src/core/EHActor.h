#pragma once
#include "library/EHLibrary.h"
#include "interface/ITickable.h"
#include "interface/ILateTickable.h"
#include "library/EHEvent.h"
#include <vector>
#include "interface/IDisplayable.h"
#include "sprite/EHSpriteManager.h"

class EHActorComponent;

struct FComponentContainer {
public:
    FName componentId;
    EHActorComponent* component;

    FComponentContainer(const FName& componentId, EHActorComponent* component) : componentId(componentId), component(component) {}
};

class EHActor
{
private:
    bool isActive;
    FVector position;
    float rotation;
    FVector scale;
    float timeScale;
    int actorId;
    FName name;

    EHActor* owner;

    std::vector<FComponentContainer> components;
    std::vector<ITickable*> tickables;
    std::vector<ILateTickable*> lateTickables;
    std::vector<IDisplayable*> displayables;

public:
    EHDelegate<bool, EHActor*> OnActorActive;
    EHActor() : isActive(true), position(FVector::Zero), rotation(0.f), scale(FVector::Zero), timeScale(1.f),
    actorId(0), name(FName()), owner(nullptr), OnActorActive(EHDelegate<bool, EHActor*>()) {}
    virtual ~EHActor();

    virtual void InitializeActor(int id);

    void TickActor(float deltaTime) const;
    void LateTickActor(float deltaTime) const;

    void SetIsActive(bool active);
    void SetPosition(const FVector& pos) { this->position = pos; }
    void SetRotation(const float rot) {this->rotation = rot; }
    void SetScale(const FVector& scl) {this->scale = scl; }
    void SetOwner(EHActor* own) { this->owner = own; }
    void SetTimeScale(const float timeScl) { this->timeScale = timeScl; }

    [[nodiscard]] bool GetIsActive() const { return isActive; }
    [[nodiscard]] FVector GetPosition() const { return position; }
    [[nodiscard]] float GetRotation() const { return rotation; }
    [[nodiscard]] FVector GetScale() const { return scale; }
    [[nodiscard]] float GetActorTimeScale() const { return timeScale; }
    [[nodiscard]] bool GetIsTickable() const { return !tickables.empty(); }
    [[nodiscard]] bool GetIsLateTickable() const { return !lateTickables.empty(); }
    [[nodiscard]] bool GetIsDisplayable() const { return !displayables.empty(); }

    [[nodiscard]] EHActor* GetOwner() const { return owner; }
    [[nodiscard]] EHActorComponent* GetActorComponent(const FName& componentId) const;
    void AddComponent(const FName& componentId, EHActorComponent* component);
    void DisplayActor(std::vector<FSpriteDisplayData>& displayData) const;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHActor, name)
};