#pragma once
#include "core/EHController.h"


class EHPlayerController : public EHController
{
private:
	EButton cachedButton;

public:
	EHPlayerController();
	void TickController() override;
	void AssignInputDevice();
};
