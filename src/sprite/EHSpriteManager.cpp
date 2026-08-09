#include "EHSpriteManager.h"
#include <iostream>
#include "library/EHJsonManager.h"

EHSpriteManager::EHSpriteManager()
{
	textureMap = std::unordered_map<unsigned long, sf::Texture*>();
	spriteMap = std::unordered_map<FName, FSpriteDrawData>();
}

EHSpriteManager::~EHSpriteManager()
{
	for (const auto& pair : textureMap)
	{
		if (pair.second != nullptr) delete pair.second;
	}
}

void EHSpriteManager::LoadSpriteMetaData(const std::string& spriteMetaPath)
{
	if (spriteMetaPath.empty())
	{
		std::cout << "Invalid SpriteMetaPath Path. Can not be empty" << std::endl;
		return;
	}

	FSpriteMetaData spriteMetaData;

	if (!EHJsonManager::Deserialize<FSpriteMetaData>(spriteMetaPath, spriteMetaData))
	{
		std::cout << "Failed to Load Sprite MetaData at path: " << spriteMetaPath << std::endl;
		return;
	}

	unsigned long textureId = FName::StringToHash(spriteMetaData.spriteFilePath);
	if (textureMap.contains(textureId))
	{
		std::cout << "Texture Is Already Loaded: " + spriteMetaPath << std::endl;
		return;
	}
	sf::Texture* texture = new sf::Texture();
	if (!texture->loadFromFile(spriteMetaData.spriteFilePath))
	{
		std::cout << "Failed to load sprite at path: " << spriteMetaPath << std::endl;
		delete texture;
		return;
	}
	textureMap.insert({ textureId, texture });

	for (const auto& spriteData : spriteMetaData.sprites)
	{
		spriteMap.insert({ spriteData.spriteId, FSpriteDrawData(texture, spriteData) });
	}
}

void EHSpriteManager::UnloadSpriteData(const std::string& spriteMetaPath)
{
	if (spriteMetaPath.empty())
	{
		std::cout << "Invalid SpriteMetaPath. Can not be empty" << spriteMetaPath << std::endl;
		return;
	}

	FSpriteMetaData spriteMetaData;
	if (!EHJsonManager::Deserialize<FSpriteMetaData>(spriteMetaPath, spriteMetaData))
	{
		std::cout << "Failed to load sprite metadata at path: " << spriteMetaPath << std::endl;
		return;
	}

	unsigned long textureId = FName::StringToHash(spriteMetaData.spriteFilePath);
	if (!textureMap.contains(textureId))
	{
		std::cout << "Texture Id was not found. Perhaps this path has not been loaded yet?" << std::endl;
		return;
	}
	sf::Texture* texture = new sf::Texture();
	if (!texture->loadFromFile(spriteMetaData.spriteFilePath))
	{

	}
}