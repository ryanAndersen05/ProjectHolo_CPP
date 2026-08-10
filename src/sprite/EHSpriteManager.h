#pragma once
#include <SFML/Graphics.hpp>
#include "EHSpriteData.h"
#include "library/EHLibrary.h"
#include <unordered_map>

struct FSpriteDrawData
{
public:
	sf::Texture* texture;
	FSpriteData spriteData;

public:
	FSpriteDrawData() : texture(nullptr), spriteData(FSpriteData()) {}
	FSpriteDrawData(sf::Texture* texture, const FSpriteData& spriteData) : texture(texture), spriteData(spriteData) {}
};

class EHSpriteManager
{
private:
	std::unordered_map<unsigned long, sf::Texture*> textureMap;
	std::unordered_map<FName, FSpriteDrawData> spriteMap;

public:
	EHSpriteManager();
	~EHSpriteManager();
	bool GetSprteDrawData(const FName& spriteId, FSpriteDrawData& drawData) const;
	void LoadSpriteMetaData(const std::string& spriteMetaPath);
	void UnloadSpriteData(const std::string& spriteMetaPath);
};