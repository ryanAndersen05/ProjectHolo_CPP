#include "EHSpriteManager.h"
#include <iostream>

#include "core/EHGameInstance.h"
#include "library/EHJsonManager.h"

EHSpriteManager::EHSpriteManager()
{
	textureMap = std::unordered_map<FName, sf::Texture*>();
	spriteMap = std::unordered_map<FName, FSpriteDrawData>();
}

EHSpriteManager::~EHSpriteManager()
{
	for (const auto& pair : textureMap)
	{
		delete pair.second;
	}
}

bool EHSpriteManager::GetSpriteDrawData(const FName &spriteId, FSpriteDrawData& drawData) const {
	if (spriteMap.contains(spriteId)) {
		drawData = spriteMap.at(spriteId);
		return true;
	}
	return false;
}

void EHSpriteManager::LoadSpriteMetaData(const FName& spriteMetaAsset)
{
	if (textureMap.contains(spriteMetaAsset))
	{
		return;
	}

	FSpriteMetaData spriteMetaData;
	if (!EHGameInstance::LoadAsset<FSpriteMetaData>(spriteMetaAsset, spriteMetaData))
	{
		std::cout << "Failed to Load Sprite MetaData at path: " << spriteMetaAsset << std::endl;
		return;
	}
	auto* texture = new sf::Texture();
	std::string texturePath;
	if (!EHGameInstance::GetAssetPath(spriteMetaData.spriteAsset, texturePath)) {
		std::cerr << "Failed to find data path for texture with Id: " << spriteMetaAsset.GetKey() << std::endl;
		return;
	}
	if (!texture->loadFromFile(texturePath))
	{
		std::cout << "Failed to load sprite at path: " << spriteMetaAsset << std::endl;
		delete texture;
		return;
	}
	textureMap.insert({ spriteMetaAsset, texture });
	for (const auto& spriteData : spriteMetaData.sprites)
	{
		spriteMap.insert({ spriteData.spriteId, FSpriteDrawData(texture, spriteData) });
	}
}

void EHSpriteManager::UnloadSpriteData(const FName& spriteMetaPath)
{
	if (!textureMap.contains(spriteMetaPath)) {
		return;
	}

	FSpriteMetaData spriteMetaData;
	if (!EHGameInstance::LoadAsset<FSpriteMetaData>(spriteMetaPath, spriteMetaData))
	{
		std::cout << "Failed to load sprite metadata at path: " << spriteMetaPath << std::endl;
		return;
	}
	for (const auto& spriteData : spriteMetaData.sprites) {
		spriteMap.erase(spriteData.spriteId);
	}

	delete textureMap[spriteMetaPath];
	textureMap.erase(spriteMetaPath);
}