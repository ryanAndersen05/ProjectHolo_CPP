#pragma once

#include <vector>
#include <functional>

class EHUserSettings {
private:
    std::vector<std::function<void>> OnSettingsChanged;

public:
    static constexpr int ScreenWidth = 1920;
    static constexpr int ScreenHeight = 1080;
    bool IsVerticalSync = false;
};