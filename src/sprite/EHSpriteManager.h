#pragma once
#include <SFML/Graphics.hpp>
#include "EHSpriteData.h"
#include "library/EHLibrary.h"
#include <unordered_map>
#include <utility>

struct FSpriteDrawData
{
public:
	sf::Texture* texture;
	FSpriteData spriteData;

public:
	FSpriteDrawData() : texture(nullptr), spriteData(FSpriteData()) {}
	FSpriteDrawData(sf::Texture* texture, FSpriteData  spriteData) :
	texture(texture), spriteData(std::move(spriteData)) {}
};

struct FSpriteDisplayData {
public:
	FSpriteDrawData drawData;
	int drawOrder;
	FVector position;
	FVector scale;
	float rotation;

	FSpriteDisplayData(FSpriteDrawData drawData, int drawOrder, const FVector& position, const FVector& scale, float rotation) :
	drawData(std::move(drawData)), drawOrder(drawOrder), position(position), scale(scale), rotation(rotation) {}
};

class EHSpriteManager
{
private:
	std::unordered_map<FName, sf::Texture*> textureMap;
	std::unordered_map<FName, FSpriteDrawData> spriteMap;

public:
	EHSpriteManager();
	~EHSpriteManager();
	bool GetSpriteDrawData(const FName& spriteId, FSpriteDrawData& drawData) const;
	void LoadSpriteMetaData(const FName& spriteMetaAsset);
	void UnloadSpriteData(const FName& spriteMetaPath);
};