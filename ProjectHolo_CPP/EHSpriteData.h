#pragma once
#include "EHLibrary.h"

#include <string>
#include <nlohmann/json.hpp>

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

	friend void to_json(json& j, const FSpriteData& spriteData);
	friend void from_json(const json& j, FSpriteData& spriteData);
};

struct FSpriteMetaData
{
public:
	std::string spriteFilePath;
	std::vector<FSpriteData> sprites;
	FSpriteMetaData() : spriteFilePath(""), sprites(std::vector<FSpriteData>()) {}

	bool GetSpriteData(const FName& spriteId, FSpriteData& outSpriteData) const;
	std::string to_string();

	friend void to_json(json& j, const FSpriteMetaData& spriteMeta);
	friend void from_json(const json& j, FSpriteMetaData& spriteMeta);
};