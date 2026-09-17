#include "EHLuaScriptSystem.h"

#include "animation/EHAnimatorComponent.h"
#include "character/EHCharacterMovementComponent.h"
#include "core/EHGameInstance.h"
#include "core/EHActor.h"
#include "sprite/EHSpriteComponent.h"


EHLuaScriptSystem::EHLuaScriptSystem() {
    loadedLibraries = std::unordered_map<FName, FLuaTableContainer>();
}

void EHLuaScriptSystem::InitializeScripting() {
    lua.open_libraries(sol::lib::base, sol::lib::io, sol::lib::math, sol::lib::table, sol::lib::string, sol::lib::package);

    lua.new_usertype<EHSpriteComponent>("SpriteComponent",
        "SetSprite", &EHSpriteComponent::SetDrawData_Lua);

    lua.new_usertype<EHAnimatorComponent>("AnimatorComponent",
        "GetBool", [](EHAnimatorComponent& self, const std::string& parameter)-> bool {
            return self.GetBool(FName(parameter));
        },
        "GetInt", [](EHAnimatorComponent& self, const std::string& parameter)-> int {
            return self.GetInt(FName(parameter));
        },
        "GetFloat", [](EHAnimatorComponent& self, const std::string& parameter)-> float {
            return self.GetFloat(FName(parameter));
        },
        "ResetTrigger", [](EHAnimatorComponent& self, const std::string& parameter) -> void {
            self.ResetTrigger(FName(parameter));
        });

    lua.new_usertype<EHCharacterMovementComponent>("Movement",
        "SetMovement", [](EHCharacterMovementComponent& self, const int movementType) -> void {
            self.SetMovementType(static_cast<EMovementType>(movementType));
        });

    lua.new_usertype<EHActor>("Actor",
        "Sprite", [](const EHActor& self, const sol::optional<std::string>& name) -> EHSpriteComponent* {
            const FName key(name.value_or("sprite"));
            return dynamic_cast<EHSpriteComponent*>(self.GetActorComponent(key));
        },
        "Animator", [](const EHActor& self, const sol::optional<std::string>& name) -> EHAnimatorComponent* {
            const FName key(name.value_or("animator"));
            return dynamic_cast<EHAnimatorComponent*>(self.GetActorComponent(key));
        },
        "Movement", [](const EHActor& self, const sol::optional<std::string>& name) -> EHCharacterMovementComponent* {
            const FName key(name.value_or("movement"));
            return dynamic_cast<EHCharacterMovementComponent*>(self.GetActorComponent(key));
        });
}

void EHLuaScriptSystem::LoadTable(const FName& libFileAsset) {
    if (!loadedLibraries.contains(libFileAsset)) {
        FLuaTableContainer tableContainer;
        tableContainer.count = 0;
        std::string pathString;
        if (!EHGameInstance::GetAssetPath(libFileAsset, pathString)) {
            std::cout << "LoadTable() - Unable to find asset path for lua script" << std::endl;
            return;
        }
        auto result = lua.safe_script_file(pathString);
        if (!result.valid()) {
            sol::error err = result;
            std::cerr << "Error Loading Lua Script: " << err.what() << std::endl;
            return;
        }
        tableContainer.table = result;
        loadedLibraries.insert(std::make_pair(libFileAsset, tableContainer));
    }

    loadedLibraries[libFileAsset].count++;
}

void EHLuaScriptSystem::UnloadTable(const FName& libFileAsset) {
    if (!loadedLibraries.contains(libFileAsset)) {
        std::cout << "UnloadTable() - Unable to find asset path for lua script" << std::endl;
        return;
    }
    loadedLibraries[libFileAsset].count--;
    if (loadedLibraries[libFileAsset].count <= 0) {
        loadedLibraries.erase(libFileAsset);
    }
}

sol::table EHLuaScriptSystem::GetTable(const FName &libFileAsset) {
    if (loadedLibraries.contains(libFileAsset)) {
        return loadedLibraries[libFileAsset].table;
    }
    std::cout << "GetTable() - Unable to find asset path for lua script" << std::endl;
    return sol::nil;
}
