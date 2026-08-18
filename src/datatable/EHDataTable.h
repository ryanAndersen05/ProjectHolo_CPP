#pragma once
#include "library/EHLibrary.h"
#include "library/EHJsonManager.h"
#include <vector>
#include <string>


class EHDataTableRow {
private:
    FName rowId;
public:
    const FName& GetRowId() const { return rowId; }

NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHDataTableRow, rowId)
};
template <typename T>
concept DataTableRow = std::derived_from<T, EHDataTableRow>;

template<DataTableRow T>
class EHDataTable {
    std::vector<T> rows;

public:
    EHDataTable() = default;

    static EHDataTable<T>* LoadDataTableFromJson(const std::string& path) {
        json dataJson;
        EHJsonManager::DeserializeAsJson(path, dataJson);
        json rowsJson = dataJson.at("rows");
        EHDataTable<T>* dataTable = new EHDataTable<T>();

        for (const auto& row : rowsJson) {
            dataTable->rows.push_back(row.get<T>());
        }
        return dataTable;
    }

    bool FindRow(const FName& rowId, T& row) const {
        for (const auto& r : rows) {
            if (r.GetRowId() == rowId) {
                row = r;
                return true;
            }
        }
        return false;
    }
};