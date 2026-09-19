#include "EHAnimatorComponent.h"
#include "core/EHGameInstance.h"
#include "sprite/EHSpriteManager.h"


void EHAnimatorComponent::Tick(float)
{
    sol::table state = stateMachineTable[currentState.GetKey()];
    if (state.valid()) {
        sol::protected_function tickFunction = state["tick"];
        if (tickFunction.valid()) {
            sol::protected_function_result result = tickFunction(state, GetActor(), frame);
            if (result.valid()) {
                if (result.get_type() == sol::type::string) {
                    // If we get a string result it will tell us that we need to change to a new state
                    SetCurrentState(FName(result.get<std::string>()));
                    return;
                }
            }
        }
    }
    frame++;
}

void EHAnimatorComponent::InitializeComponent(EHActor *actr) {
    EHActorComponent::InitializeComponent(actr);
    EHLuaScriptSystem* luaScripting = EHGameInstance::GetInstance()->GetLuaScriptSystem();
    if (!luaScripting) {
        std::cout << "InitializeComponent() - LuaScriptSystem not found: " << std::endl;
        return;
    }
    luaScripting->LoadTable(stateMachineAsset);
    stateMachineTable = luaScripting->GetTable(stateMachineAsset);
    if (stateMachineTable.valid()) {
        sol::optional<std::string> defaultState = stateMachineTable["defaultState"];
        SetCurrentState(defaultState.value_or(""));
        sol::optional<std::string> spriteAsset = stateMachineTable["spriteAsset"];
        if (EHSpriteManager* spriteManager = EHGameInstance::GetInstance()->GetSpriteManager()) {
            spriteManager->LoadSpriteMetaData(FName(spriteAsset.value_or("")));
        }
        sol::table parameterTable = stateMachineTable["parameters"];
        for (const auto& tablePair : parameterTable) {
            sol::object key = tablePair.first;
            sol::object value = tablePair.second;
            FName parameterKey;
            EParameterType parameterType = EParameterType::None;
            if (key.is<std::string>()) {
                parameterKey = FName(key.as<std::string>());
            }
            if (value.is<int>()) {
                parameterType = static_cast<EParameterType>(value.as<int>());
            }
            parameters.emplace(parameterKey, FParameterValue());
            switch (parameterType) {
                case EParameterType::Bool: parameters[parameterKey].bValue = false; break;
                case EParameterType::Int: parameters[parameterKey].iValue = 0; break;
                case EParameterType::Float: parameters[parameterKey].fValue = 0; break;
                case EParameterType::Trigger: parameters[parameterKey].bValue = false; break;
                default: std::cout << "InitializeComponent() - Invalid parameter type: " << std::endl;
            }
        }
    }
}

void EHAnimatorComponent::SetCurrentState(const FName& newState) {
    if (currentState == newState) return;
    frame = 0;

    if (currentState.IsValid()) {
        sol::table oldStateTable = stateMachineTable[currentState.GetKey()];
        if (oldStateTable.valid()) {
            sol::protected_function onExit = oldStateTable["onExit"];
            if (onExit.valid()) onExit(GetActor());
        }
    }

    currentState = newState;
    if (currentState.IsValid()) {
        sol::table newStateTable = stateMachineTable[currentState.GetKey()];
        if (newStateTable.valid()) {
            sol::protected_function onEnter = newStateTable["onEnter"];
            if (onEnter.valid()) {
                sol::protected_function_result result = onEnter(GetActor());
                if (result.valid() && result.get_type() == sol::type::string) {
                    SetCurrentState(FName(result.get<std::string>()));
                }
            }
        }
    }
}

bool EHAnimatorComponent::GetBool(const FName& parameter) {
    if (!parameters.contains(parameter)) {
        std::cout << "EHAnimatorComponent::GetBool() - Parameter not found: " << parameter.GetKey() << std::endl;
        return false;
    }
    return parameters[parameter].bValue;
}

int EHAnimatorComponent::GetInt(const FName& parameter) {
    if (!parameters.contains(parameter)) {
        std::cout << "EHAnimatorComponent::GetInt() - Parameter not found: " << parameter.GetKey() << std::endl;
        return 0;
    }
    return parameters[parameter].iValue;
}

float EHAnimatorComponent::GetFloat(const FName& parameter) {
    if (!parameters.contains(parameter)) {
        std::cout << "EHAnimatorComponent::GetFloat() - Parameter not found: " << parameter.GetKey() << std::endl;
        return 0;
    }
    return parameters[parameter].fValue;
}

void EHAnimatorComponent::SetBool(const FName &parameter, bool value) {
    if (!parameters.contains(parameter)) {
        std::cout << "EHAnimatorComponent::SetBool() - Parameter not found: " << parameter.GetKey() << std::endl;
        return;
    }
    parameters[parameter].bValue = value;
}

void EHAnimatorComponent::SetInt(const FName& parameter, int value) {
    if (!parameters.contains(parameter)) {
        std::cout << "EhAnimatorComponent::SetInt() - Parameter not found: " << parameter.GetKey() << std::endl;
        return;
    }
    parameters[parameter].iValue = value;
}

void EHAnimatorComponent::SetFloat(const FName& parameter, float value) {
    if (!parameters.contains(parameter)) {
        std::cout << "EHAnimatorComponent::SetFloat() - Parameter not found: " << parameter.GetKey() << std::endl;
        return;
    }
    parameters[parameter].fValue = value;
}

void EHAnimatorComponent::SetTrigger(const FName &parameter) {
    SetBool(parameter, true);
}

void EHAnimatorComponent::ResetTrigger(const FName &parameter) {
    SetBool(parameter, false);
}
