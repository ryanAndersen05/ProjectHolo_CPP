#pragma once

#include <vector>
#include <functional>

class EHUserSettings {
private:
    std::vector<std::function<void>> OnSettingsChanged;

public:
    static constexpr int ScreenWidth = 240;
    static constexpr int ScreenHeight = 135;
    bool IsVerticalSync = false;
};