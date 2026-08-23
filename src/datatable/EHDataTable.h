#pragma once
#include "library/EHLibrary.h"
#include "library/EHJsonManager.h"
#include <vector>
#include <string>
#include "nlohmann/json.hpp"

using json = nlohmann::json;


class EHDataTableRow {
private:
    FName rowId;
public:
    [[nodiscard]] const FName& GetRowId() const { return rowId; }

NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHDataTableRow, rowId)
};
template <typename T>
concept DataTableRow = std::derived_from<T, EHDataTableRow>;

template<DataTableRow T>
class EHDataTable {
    std::vector<T> rows;

public:
    EHDataTable() = default;

    bool FindRow(const FName& rowId, T& row) const {
        for (const auto& r : rows) {
            if (r.GetRowId() == rowId) {
                row = r;
                return true;
            }
        }
        return false;
    }

    friend void from_json(const json& j, EHDataTable<T>& table) {
        json rowsJson = j.at("rows");

        for (const auto& row : rowsJson) {
            table.rows.push_back(row.get<T>());
        }
    }
};