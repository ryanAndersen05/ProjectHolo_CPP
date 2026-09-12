#include "EHLuaScriptSystem.h"
#include "core/EHGameInstance.h"
#include "core/EHActor.h"
#include "sprite/EHSpriteComponent.h"


EHLuaScriptSystem::EHLuaScriptSystem() {
    loadedLibraries = std::unordered_map<FName, FLuaTableContainer>();
}

void EHLuaScriptSystem::InitializeScripting() {
    lua.open_libraries(sol::lib::base, sol::lib::io, sol::lib::math, sol::lib::table, sol::lib::string);

    lua.new_usertype<EHSpriteComponent>("SpriteComponent",
        "SetSprite", &EHSpriteComponent::SetDrawData_Lua);

    lua.new_usertype<EHActor>("Actor",
        "Sprite", [](const EHActor& self, sol::optional<std::string> name) -> EHSpriteComponent* {
            FName key(name.value_or("sprite"));
            return dynamic_cast<EHSpriteComponent*>(self.GetActorComponent(key));
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
