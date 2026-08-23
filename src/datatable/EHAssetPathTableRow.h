#pragma once
#include "EHDataTable.h"

class EHAssetPathTableRow : public EHDataTableRow {
private:
    std::string assetPath;
public:
    EHAssetPathTableRow() : EHDataTableRow(), assetPath() {}
    [[nodiscard]] const std::string& GetAssetPath() const { return assetPath; }
    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(EHAssetPathTableRow, EHDataTableRow, assetPath)
};