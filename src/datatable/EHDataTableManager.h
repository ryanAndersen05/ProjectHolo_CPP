#pragma once
#include "EHCharacterTableRow.h"
#include "EHDataTable.h"

class EHDataTableManager {
private:
    EHDataTable<EHCharacterTableRow> characterDataTable;
public:
    EHDataTableManager();
    bool GetCharacterDataById(const FName& rowId, EHCharacterTableRow& data) const {return characterDataTable.FindRow(rowId, data);};
};
