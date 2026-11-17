//
// Created by ryana on 11/4/2026.
//

#ifndef MAINGAMELEVEL_JSON_EHGAMEPLAYTAG_H
#define MAINGAMELEVEL_JSON_EHGAMEPLAYTAG_H

#include "library/EHLibrary.h"

struct FGameplayTagGrant {
    FName tag;
    int count = 1;
};
void from_json(const json& data, FGameplayTagGrant& grant);

#endif //MAINGAMELEVEL_JSON_EHGAMEPLAYTAG_H
