#include "EHInputMap.h"

EHInputMap::~EHInputMap() {
    for (FInputAction* action : actions) {
        delete action;
    }
}

FInputAction *EHInputMap::FindAction(const FName &actionName) const {
    for (FInputAction* action : actions) {
        if (action->GetName() == actionName) return action;
    }
    return nullptr;
}

void from_json(const json& j, EHInputMap& inputMap) {
    json actionList = j.at("actions");
    for (auto& action : actionList) {
        inputMap.actions.push_back(new FInputAction(action.get<FInputAction>()));
    }
}