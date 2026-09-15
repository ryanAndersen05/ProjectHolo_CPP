#pragma once
#include "core/EHController.h"
#include "input/EHInputAction.h"
#include "input/EHInputMap.h"


class EHPlayerController : public EHController
{
private:
	static const FName LightAttackAction;
	static const FName MediumAttackAction;
	static const FName HeavyAttackAction;
	static const FName SpecialAttackAction;
	static const FName MoveHorizontalAction;
	static const FName MoveVerticalAction;
	static constexpr float JoystickDeadZone = 0.35f;

	EButton cachedButton;
	EButton previousButton;
	void ModifyCachedButton(EButton button, bool isPressed);
	EHInputMap inputMap;

public:
	EHPlayerController();
	~EHPlayerController() override;
	void OnLightButtonAction(const FInputContext& inputContext) {
		std::cout << "OnLightButtonAction: " << inputContext.GetValueAsButton() << std::endl;
		ModifyCachedButton(EButton::Light, inputContext.GetValueAsButton());
	}
	void OnMediumButtonAction(const FInputContext& inputContext) { ModifyCachedButton(EButton::Medium, inputContext.GetValueAsButton()); }
	void OnHeavyButtonAction(const FInputContext& inputContext) { ModifyCachedButton(EButton::Heavy, inputContext.GetValueAsButton()); }
	void OnSpecialButtonAction(const FInputContext& inputContext) { ModifyCachedButton(EButton::Special, inputContext.GetValueAsButton()); }
	void OnMoveHorizontalAction(const FInputContext& inputContext);
	void OnMoveVerticalAction(const FInputContext& inputContext);

	// void TickController() override;
	void AssignInputDevice();
};
