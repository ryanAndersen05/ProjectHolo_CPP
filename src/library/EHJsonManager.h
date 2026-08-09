#pragma once
#include <string>
#include <iostream>
#include <fstream>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

class EHJsonManager
{
public:
	template<typename T>
	static bool Deserialize(const std::string& path, T& outValue)
	{
		std::ifstream file(path);
		if (!file.is_open())
		{
			std::cerr << "Error opening file" << std::endl;
			return false;
		}

		try
		{
			json data = json::parse(file);
			outValue = data.get<T>();
			return true;
		}
		catch (const json::parse_error& e)
		{
			std::cerr << "Json Parse Error: " << e.what() << std::endl;
		}
		return false;
	}
};