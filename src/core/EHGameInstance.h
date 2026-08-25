#pragma once
#include "sprite/EHSpriteManager.h"
#include "EHGameMode.h"
#include "EHGameHUD.h"
#include "datatable/EHDataTableManager.h"
#include "datatable/EHAssetPathTableRow.h"
#include "nlohmann/json.hpp"
#include <string>
#include "library/EHJsonManager.h"

using json = nlohmann::json;

struct FWorldSettings {
public:
	FName gameMode;
	FName gameHUD;
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FWorldSettings, gameMode, gameHUD)


class EHGameInstance
{
private:
	static EHGameInstance* instance;
	// World
	EHGameMode* gameMode;
	EHGameHUD* gameHUD;

	EHDataTable<EHAssetPathTableRow> assetPathTable;
	EHSpriteManager* spriteManager;
	EHDataTableManager* dataTableManager;

	template<typename T>
	bool LoadAsset_Instance(const FName& assetId, T& asset) {
		EHAssetPathTableRow assetRow;
		if (!assetPathTable.FindRow(assetId, assetRow)) {
			std::cout << "Failed to find asset for ID: " << assetId.GetKey() << std::endl;
			return false;
		}
		return EHJsonManager::Deserialize<T>(assetRow.GetAssetPath(), asset);
	}

	bool LoadAssetAsJson_Instance(const FName& assetId, json& assetJson) const {
		EHAssetPathTableRow assetRow;
		if (!assetPathTable.FindRow(assetId, assetRow)) {
			std::cout << "Failed to find asset for ID: " << assetId.GetKey() << std::endl;
			return false;
		}
		return EHJsonManager::DeserializeAsJson(assetRow.GetAssetPath(), assetJson);
	}

	bool GetAssetPath_Instance(const FName& assetId, std::string& assetPath) const {
		EHAssetPathTableRow assetRow;
		if (!assetPathTable.FindRow(assetId, assetRow)) {
			std::cout << "Failed to find asset for ID: " << assetId.GetKey() << std::endl;
			return false;
		}
		assetPath = assetRow.GetAssetPath();
		return true;
	}

public:
	EHGameInstance();
	~EHGameInstance();
	[[nodiscard]] EHSpriteManager* GetSpriteManager() const { return spriteManager;}
	[[nodiscard]] EHDataTableManager* GetDataTableManager() const { return dataTableManager;}
	static EHGameInstance* GetInstance() { return instance;}

	void InitializeGame(const FWorldSettings& worldSettings);
	// This will be called every game tick
	void TickGame(float deltaTime) const;
	// This will be called every graphics display tick
	void DisplayGame(sf::RenderWindow& window) const;

	template<typename T>
	static bool LoadAsset(const FName& assetId, T& asset) { return instance->LoadAsset_Instance(assetId, asset); }
	static bool LoadAssetAsJson(const FName& assetId, json& assetJson) { return instance->LoadAssetAsJson_Instance(assetId, assetJson); }
	static bool GetAssetPath(const FName& assetId, std::string& assetPath) { return instance->GetAssetPath_Instance(assetId, assetPath);}
};



struct FGameLevel {
public:
	FWorldSettings worldSettings;
	std::vector<FName> actors;
	FGameLevel() = default;
	NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FGameLevel, worldSettings, actors)
};
