#include "EHDataTableManager.h"

#include "animation/EHAnimatorController.h"

EHDataTableManager::EHDataTableManager() {
    actorDataTable = EHDataTable<EHActorTableRow>::LoadDataTableFromJson("assets/datatables/actorDataTable.json");
}

bool EHDataTableManager::GetActorData(const FName &rowId, EHActorTableRow &row) const {
    return actorDataTable->FindRow(rowId, row);
}
