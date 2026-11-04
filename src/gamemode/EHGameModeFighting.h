#pragma once
#include "core/EHGameMode.h"

class EHWorld;

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

class EHGameModeFighting : public EHGameMode {
public:
    static FGameMatchSettings MatchSettings;

private:
    static const FName WorldAssetId;
    EHWorld* world = nullptr; // Actor lifetime is owned by the base game mode.
    int colorPaletteIndex;
    int gameFrame;
    FGameMatchSettings defaultMatchSettings;

protected:
    void InitializeWorld();
    void Simulate(float deltaTime) override;

public:
    EHGameModeFighting() : EHGameMode(), colorPaletteIndex(0), gameFrame(0) {}
    void InitializeGameMode() override;
    void TickGameMode(float deltaTime) override;
    void DestroyActor(EHActor* actor) override;
    [[nodiscard]] EHWorld* GetWorld() const { return world; }

    NLOHMANN_DEFINE_TYPE_INTRUSIVE(EHGameModeFighting, defaultMatchSettings)
};
