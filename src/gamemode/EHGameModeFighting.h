#pragma once
#include "core/EHGameMode.h"

struct FPlayerSettings {
    FName characterId;
    int colorSelection;
    FName controllerType;
    int inputDeviceId;

    FPlayerSettings() : colorSelection(0), inputDeviceId(0) {}
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FPlayerSettings, characterId, colorSelection, controllerType, inputDeviceId)

struct FGameMatchSettings {
    FName sceneId;
    int winRounds;
    int secondsPerRound;
    std::vector<FPlayerSettings> playerSettings;
    [[nodiscard]] bool IsValid() const { return !playerSettings.empty(); }
    FGameMatchSettings() : winRounds(0), secondsPerRound(0) {}
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FGameMatchSettings, sceneId, winRounds, secondsPerRound, playerSettings)

class EHGameModeFighting : public EHGameMode{
public:
    static FGameMatchSettings MatchSettings;

private:
    FGameMatchSettings defaultMatchSettings;

public:
    EHGameModeFighting() : EHGameMode(), defaultMatchSettings() {}
    void InitializeGameMode() override;

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHGameModeFighting, defaultMatchSettings)
};
