#pragma once
#include "EHDataTable.h"
#include "EHAssetPathTableRow.h"

class EHDataTableManager {
    EHDataTable<EHAssetPathTableRow> assetDataTable;
public:
    EHDataTableManager();
    bool GetAssetPathData(const FName& rowId, EHAssetPathTableRow& row) const;
};
