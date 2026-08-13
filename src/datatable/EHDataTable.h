#pragma once
#include "library/EHLibrary.h"
#include <vector>
#include <string>


class EHDataTableRow {
private:
    FName rowId;
};

template <typename T>
class EHDataTable {
    std::vector<T> rows;

public:
    EHDataTable(const std::string& dataTablePath);
};