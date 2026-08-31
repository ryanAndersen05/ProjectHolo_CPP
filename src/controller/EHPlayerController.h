#pragma once
#include "core/EHController.h"
#include "input/EHInputAction.h"
#include "input/EHInputMap.h"


class EHPlayerController : public EHController
{
private:
	EButton cachedButton;
	EButton previousButton;
	void ModifyCachedButton(EButton button, bool isPressed);
	EHInputMap inputMap;

public:
	EHPlayerController();
	~EHPlayerController() override = default;
	void OnLightButtonAction(FInputContext inputContext) { ModifyCachedButton(EButton::Light, inputContext.GetValueAsButton()); }
	void OnMediumButtonAction(FInputContext inputContext) { ModifyCachedButton(EButton::Medium, inputContext.GetValueAsButton()); }
	void OnHeavyButtonAction(FInputContext inputContext) { ModifyCachedButton(EButton::Heavy, inputContext.GetValueAsButton()); }
	void OnSpecialButtonAction(FInputContext inputContext) { ModifyCachedButton(EButton::Special, inputContext.GetValueAsButton()); }

	// void TickController() override;
	void AssignInputDevice();
};
