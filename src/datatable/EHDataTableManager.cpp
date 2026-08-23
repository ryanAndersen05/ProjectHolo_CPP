#include "EHDataTableManager.h"
#include "animation/EHAnimatorController.h"
#include "core/EHGameInstance.h"

EHDataTableManager::EHDataTableManager() {
    EHGameInstance* instance = EHGameInstance::GetInstance();

    instance->LoadAsset<EHDataTable<EHAssetPathTableRow>>(FName("asset_table"), assetDataTable);
}

bool EHDataTableManager::GetAssetPathData(const FName &rowId, EHAssetPathTableRow &row) const {
    return assetDataTable.FindRow(rowId, row);
}
