#pragma once
#include "EHDataTable.h"
#include "EHActorTableRow.h"

class EHDataTableManager {
private:
    EHDataTable<EHActorTableRow>* actorDataTable;
public:
    EHDataTableManager();
    bool GetActorData(const FName& rowId, EHActorTableRow& row) const;
};
