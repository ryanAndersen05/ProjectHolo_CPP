#pragma once
#include "core/EHController.h"


class EHPlayerController : public EHController
{
private:
	EButton cachedButton;

public:
	EHPlayerController() : EHController(), cachedButton(EButton::None) {}
	void AssignInputDevice();
};