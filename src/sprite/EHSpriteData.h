#pragma once
#include <string>
#include <vector>
#include <nlohmann/json.hpp>
#include "library/EHLibrary.h"

using json = nlohmann::json;

struct FSpriteData
{
public:
	FName spriteId;
	FVectorInt point;
	FVectorInt size;
	FVectorInt pivot;
	FSpriteData() : spriteId(FName("")), point(FVectorInt::Zero), size(FVectorInt::Zero), pivot(FVectorInt::Zero) {}
	std::string to_string();
};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FSpriteData, spriteId, point, size, pivot)

struct FSpriteMetaData
{
public:
	FName spriteAsset;
	std::vector<FSpriteData> sprites;
	FSpriteMetaData() : spriteAsset(""), sprites(std::vector<FSpriteData>()) {}

	bool GetSpriteData(const FName& spriteId, FSpriteData& outSpriteData) const;
	std::string to_string();

	friend void to_json(json& j, const FSpriteMetaData& spriteMeta);
	friend void from_json(const json& j, FSpriteMetaData& spriteMeta);
};