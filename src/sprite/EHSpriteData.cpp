#include "EHSpriteData.h"
#include "library/EHLibrary.h"
#include <iostream>

bool FSpriteMetaData::GetSpriteData(const FName& spriteId, FSpriteData& outSpriteData) const
{
	for (const FSpriteData& data : sprites)
	{
		if (data.spriteId == spriteId)
		{
			outSpriteData = data;
			return true;
		}
	}
	std::cout << "GetSpriteData() - Invalid SpriteId. Could not find" << std::endl;
	return false;
}

std::string FSpriteData::to_string()
{
	return "spriteId: " + spriteId.GetKey() + "\n" +
		"point: " + point.to_string() + '\n' +
		"size: " + size.to_string() + '\n' +
		"pivot: " + pivot.to_string();
}

std::string FSpriteMetaData::to_string()
{
	std::string data = "spriteFilePath: " + spriteAsset.GetKey() + '\n';
	data += "Length: " + std::to_string(sprites.size());
	for (FSpriteData& sprite : sprites)
	{
		data += '\n' + sprite.to_string() + '\n';
	}
	return data;
}

void to_json(json& j, const FSpriteData& spriteData)
{
	j = json{ {"spriteId", spriteData.spriteId}, {"point", spriteData.point}, {"size", spriteData.size}, {"pivot", spriteData.pivot} };
}

void from_json(const json& j, FSpriteMetaData& spriteData)
{
	j.at("spriteAsset").get_to(spriteData.spriteAsset);

	for (const auto& var : j.at("sprites"))
	{
		FSpriteData data = var.get<FSpriteData>();
		spriteData.sprites.push_back(data);
	}
}