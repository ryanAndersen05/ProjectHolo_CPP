#pragma once
#include "sprite/EHSpriteManager.h"
#include "EHGameMode.h"
#include "EHGameHUD.h"
#include "nlohmann/json.hpp"

struct FWorldSettings {
public:
	std::string gameModePath;
	std::string gameHUDPath;
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FWorldSettings, gameModePath, gameHUDPath)


class EHGameInstance
{
private:
	static EHGameInstance* instance;
	EHGameMode* gameMode;
	EHGameHUD* gameHUD;
	EHSpriteManager* spriteManager;

public:
	EHGameInstance();
	EHSpriteManager* GetSpriteManager() const {return spriteManager;}
	static EHGameInstance* GetInstance() { return instance;}

	void InitializeGame(const FWorldSettings& worldSettings);
	// This will be called every game tick
	void TickGame();
	// This will be called every graphics display tick
	void DisplayGame();
};