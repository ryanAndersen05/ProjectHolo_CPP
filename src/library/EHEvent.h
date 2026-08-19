#pragma once
#include <functional>

template<typename... Args>
class EHAction {
public:
    using Callback = std::function<void(Args...)>;
};
