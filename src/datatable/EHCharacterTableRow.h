#pragma once
#include "EHDataTable.h"

class EHCharacterTableRow : public EHDataTableRow {
private:
    FName assetId;
    std::vector<FName> colorPalettes;

public:
    std::vector<FName>& GetColorPalettes() { return colorPalettes; }
    [[nodiscard]] const FName& GetAssetId() const { return assetId; }
    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(EHCharacterTableRow, EHDataTableRow, assetId, colorPalettes);
};