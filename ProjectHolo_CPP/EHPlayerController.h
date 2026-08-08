#pragma once
#include "EHController.h"


class EHPlayerController : public EHController
{
private:
	EButton cachedButton;

public:
	EHPlayerController() : cachedButton(EButton::None), EHController() {}
	void AssignInputDevice();
};