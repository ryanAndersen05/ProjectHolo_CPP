#pragma once
#include "EHAnimationTypes.h"
#include "table.hpp"
#include "core/EHActorComponent.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

class EHAnimatorComponent : public EHActorComponent, public ITickable
{
private:
    FName stateMachineAsset;

    FName currentState;
    sol::table stateMachineTable;
    std::unordered_map<FName, FParameterValue> parameters;
    int frame;

public:
    EHAnimatorComponent() : EHActorComponent(), frame(0) {}
    void InitializeComponent(EHActor *actr) override;
    void Tick(float deltaTime) override;

    [[nodiscard]] bool GetBool(const FName& parameter);
    [[nodiscard]] int GetInt(const FName& parameter);
    [[nodiscard]] float GetFloat(const FName& parameter);

    void SetBool(const FName& parameter, bool value);
    void SetInt(const FName& parameter, int value);
    void SetFloat(const FName& parameter, float value);
    void SetTrigger(const FName& parameter);
    void ResetTrigger(const FName& parameter);

    void SetCurrentState(const FName& newState);
    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHAnimatorComponent, stateMachineAsset);

private:
    void InitializeParameters();

};

