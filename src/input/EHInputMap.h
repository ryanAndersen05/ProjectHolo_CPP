#pragma once
#include "EHInputAction.h"
#include "nlohmann/json.hpp"

using json = nlohmann::json;

class EHInputMap {
private:
    std::vector<FInputAction*> actions;
    unsigned int joystickId;
    bool isKeyboard;
public:
    EHInputMap() = default;
    ~EHInputMap();
    [[nodiscard]] FInputAction* FindAction(const FName& actionName) const;

    void RebindJoystickAction(const FName& actionName, unsigned int joystickId);
    void RebindKeyboardAction(const FName& actionName, sf::Keyboard::Key keyboardId);

    friend void from_json(const json& j, EHInputMap& inputMap);
};
