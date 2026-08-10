#pragma once
#include "sprite/EHSpriteManager.h"

class EHGameInstance
{
private:
	static EHGameInstance* instance;

	EHSpriteManager* spriteManager;

public:
	EHGameInstance();
	EHSpriteManager* GetSpriteManager() const {return spriteManager;}

	static EHGameInstance* GetInstance() { return instance;}

	void InitializeGame();

};