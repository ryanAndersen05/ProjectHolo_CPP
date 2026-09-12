#pragma once
#include "library/EHLibrary.h"
#define SOL_ALL_SAFETIES_ON 1
#include <sol/sol.hpp>


struct FLuaTableContainer {
    sol::table table;
    int count;
    FLuaTableContainer() : count(0) {}
};

class EHLuaScriptSystem {
private:
    sol::state lua;
    std::unordered_map<FName, FLuaTableContainer> loadedLibraries;


public:
    EHLuaScriptSystem();
    void InitializeScripting();
    void UninitializeScripting();

    void LoadTable(const FName& libFileAsset);
    void UnloadTable(const FName& libFileAsset);
    sol::table GetTable(const FName& libFileAsset);
};