#pragma once
#include <cstdint>
#include <functional>
#include <iostream>


template<typename... Args>
class EHDelegate {
public:
    using Callback = std::function<void(Args...)>;
private:
    struct FCallbackEntry {
        uint32_t id;
        Callback callback;
    };

public:
    EHDelegate() : nextId(0) {}

    uint32_t AddListener(Callback callback) {
        std::uint32_t newId = nextId++;
        callbacks.push_back(
            {
                newId,
                std::move(callback)
            });
        return newId;
    }

    void RemoveListener(uint32_t id) {
        std::uint32_t count = std::erase_if(callbacks,
            [id](const FCallbackEntry entry) {
               return entry.id == id;
            });
        if (count == 0) {
            std::cout << "RemoveListener() - Did not remove value with key: " << id << std::endl;
        }
    }

    void Invoke(Args... args) {
        for (auto& callbackEntry : callbacks) {
            callbackEntry.callback(args...);
        }
    }

    void RemoveAllListeners() {
        callbacks.clear();
    }

private:
    uint32_t nextId;
    std::vector<FCallbackEntry> callbacks;
};
