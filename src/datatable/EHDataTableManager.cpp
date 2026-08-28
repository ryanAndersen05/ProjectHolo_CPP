#include "EHDataTableManager.h"

#include "core/EHGameInstance.h"

EHDataTableManager::EHDataTableManager() {
    if (!EHGameInstance::LoadAsset(FName("character_table"), characterDataTable)) {
        std::cerr << "No valid Character Table was found" << std::endl;
    }
}
