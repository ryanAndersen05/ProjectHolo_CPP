#pragma once
#include "EHDataTable.h"

class EHActorTableRow : public EHDataTableRow {
private:
    std::string actorPath;
public:
    EHActorTableRow() : EHDataTableRow(), actorPath() {}
    const std::string& GetActorPath() const { return actorPath; }
    NLOHMANN_DEFINE_DERIVED_TYPE_INTRUSIVE(EHActorTableRow, EHDataTableRow, actorPath)
};