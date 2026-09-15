#pragma once
#include "EHInputAction.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

class EHInputMap {
private:
    std::vector<FInputAction> actions;
    std::vector<unsigned int>  deviceIds;
    std::uint32_t keyboardDelegateId;
    std::uint32_t joystickDelegateId;
    std::uint32_t joystickAxisDelegateId;

    [[nodiscard]] bool ContainsId(unsigned int id) const;
public:
    EHInputMap();
    ~EHInputMap();
    [[nodiscard]] FInputAction* FindAction(const FName& actionName);

    void OnKeyboardEvent(sf::Keyboard::Key key, bool isPressed);
    void OnJoystickButtonEvent(unsigned int joystickId, unsigned int joystickButton, bool isPressed);
    void OnAxisEvent(unsigned int joystickId, sf::Joystick::Axis axis, float value);

    void RebindJoystickAction(const FName& actionName, unsigned int joystickId);
    void RebindKeyboardAction(const FName& actionName, sf::Keyboard::Key keyboardId);

    friend void from_json(const json& j, EHInputMap& inputMap);
};
