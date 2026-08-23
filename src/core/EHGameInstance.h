#pragma once
#include "sprite/EHSpriteManager.h"
#include "EHGameMode.h"
#include "EHGameHUD.h"
#include "datatable/EHDataTableManager.h"
#include "nlohmann/json.hpp"
#include <string>
#include "library/EHJsonManager.h"

using json = nlohmann::json;

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
	// World
	EHGameMode* gameMode;
	EHGameHUD* gameHUD;

	EHSpriteManager* spriteManager;
	EHDataTableManager* dataTableManager;

public:
	EHGameInstance();
	~EHGameInstance();
	[[nodiscard]] EHSpriteManager* GetSpriteManager() const { return spriteManager;}
	[[nodiscard]] EHDataTableManager* GetDataTableManager() const { return dataTableManager;}
	static EHGameInstance* GetInstance() { return instance;}

	void InitializeGame(const FWorldSettings& worldSettings);
	// This will be called every game tick
	void TickGame() const;
	// This will be called every graphics display tick
	void DisplayGame();

	template<typename T>
	bool LoadAsset(const FName& assetId, T& asset) {
		EHAssetPathTableRow assetRow;
		if (!dataTableManager->GetAssetPathData(assetId, assetRow)) {
			std::cout << "Failed to find asset for ID: " << assetId.GetKey() << std::endl;
			return false;
		}
		return EHJsonManager::Deserialize<T>(assetRow.GetAssetPath(), asset);
	}
};



struct FGameLevel {
public:
	FWorldSettings worldSettings;
	std::vector<FName> actors;
	FGameLevel() = default;
};
