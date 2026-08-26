#pragma once
#include "EHDataTable.h"

class EHCharacterTableRow : public EHDataTableRow {
private:
    FName assetId;
    std::vector<FName> colorPalettes;

    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(EHCharacterTableRow, EHDataTableRow, assetId, colorPalettes);
};