#pragma once
#include "EHDataTable.h"

class EHCharacterTableRow : public EHDataTableRow {
private:
    FName assetId;
    std::vector<FName> colorPalettes;

public:
    std::vector<FName>& GetColorPalettes() { return colorPalettes; }
    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(EHCharacterTableRow, EHDataTableRow, assetId, colorPalettes);
};