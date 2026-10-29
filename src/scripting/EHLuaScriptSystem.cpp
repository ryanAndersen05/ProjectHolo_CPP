#include "EHLuaScriptSystem.h"

#include "animation/EHAnimatorComponent.h"
#include "character/EHCharacterMovementComponent.h"
#include "core/EHGameInstance.h"
#include "core/EHActor.h"
#include "factory/EHActorComponentFactory.h"
#include "hitbox/EHHitboxComponent.h"
#include "sprite/EHSpriteComponent.h"

namespace {
    sol::variadic_results LuaGeometry(sol::this_state state, const std::optional<FVector>& vector) {
        sol::variadic_results result;
        if (vector) {
            result.push_back(sol::make_object(state, vector->x));
            result.push_back(sol::make_object(state, vector->y));
        }
        else result.push_back(sol::make_object(state, sol::nil));
        return result;
    }

    sol::variadic_results LuaGeometry(sol::this_state state, const std::optional<FRect>& bounds) {
        sol::variadic_results result;
        if (bounds) {
            const FVector position = bounds->GetPosition();
            const FVector size = bounds->GetSize();
            result.push_back(sol::make_object(state, position.x));
            result.push_back(sol::make_object(state, position.y));
            result.push_back(sol::make_object(state, size.x));
            result.push_back(sol::make_object(state, size.y));
        }
        else result.push_back(sol::make_object(state, sol::nil));
        return result;
    }
}

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
        },
        "Jump", [](EHCharacterMovementComponent& self) -> void {
            self.AttemptJump();
        });

    lua.new_enum<EHHitboxType>("HitboxType", {
        {"Hitbox", EHHitboxType::Hitbox},
        {"Hurtbox", EHHitboxType::Hurtbox}
    });

    lua.new_usertype<EHHitboxComponent>("HitboxComponent", sol::no_constructor,
        // "HasHitbox", [](const EHHitboxComponent& self, const std::string& name) {
        //     return self.HasHitbox(FName(name));
        // },
        // "GetType", [](const EHHitboxComponent& self, const std::string& name) {
        //     return self.GetType(FName(name));
        // },
        // "IsActive", [](const EHHitboxComponent& self, const std::string& name) {
        //     return self.IsActive(FName(name));
        // },
        // "GetPosition", [](const EHHitboxComponent& self, const std::string& name, sol::this_state state) {
        //     return LuaGeometry(state, self.GetPosition(FName(name)));
        // },
        // "GetSize", [](const EHHitboxComponent& self, const std::string& name, sol::this_state state) {
        //     return LuaGeometry(state, self.GetSize(FName(name)));
        // },
        // "GetLocalBounds", [](const EHHitboxComponent& self, const std::string& name, sol::this_state state) {
        //     return LuaGeometry(state, self.GetLocalBounds(FName(name)));
        // },
        // "GetWorldBounds", [](const EHHitboxComponent& self, const std::string& name, sol::this_state state) {
        //     return LuaGeometry(state, self.GetWorldBounds(FName(name)));
        // },
        "SetActive", [](EHHitboxComponent& self, const std::string& name, bool active) {
            return self.SetActive(FName(name), active);
        },
        "SetPosition", [](EHHitboxComponent& self, const std::string& name, float x, float y) {
            return self.SetPosition(FName(name), FVector(x, y));
        },
        "SetSize", [](EHHitboxComponent& self, const std::string& name, float width, float height) {
            return self.SetSize(FName(name), FVector(width, height));
        },
        "SetBounds", [](EHHitboxComponent& self, const std::string& name,
            float x, float y, float width, float height) {
            return self.SetBounds(FName(name), FVector(x, y), FVector(width, height));
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
        },
        "Hitbox", [](const EHActor& self, const sol::optional<std::string>& name) -> EHHitboxComponent* {
            const FName key = name ? FName(*name) : EHActorComponentFactory::HitboxComponentId;
            return dynamic_cast<EHHitboxComponent*>(self.GetActorComponent(key));
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
