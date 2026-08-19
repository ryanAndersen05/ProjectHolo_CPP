#pragma once
#include <cstdint>
#include <functional>
#include <bits/fs_fwd.h>


template<typename... Args>
class EHAction {
public:
    using Callback = std::function<void(Args...)>;
private:
    struct FCallbackEntry {
        uint32_t id;
        Callback callback;
    };

public:


    EHAction() : nextId(0) {}

    uint32_t AddListener(Callback callback) {
        int newId = nextId++;
        callbacks.push_back(
            {
                newId,
                std::move(callback)
            });
        return newId;
    }

    void RemoveListener(uint32_t id) {
        std::erase_if(callbacks,
            [id](const FCallbackEntry entry) {
               return entry.id == id;
            });
    }

    void Invoke(Args... args) {
        for (auto& callbackEntry : callbacks) {
            callbackEntry.callback(args...);
        }
    }

private:
    uint32_t nextId;
    std::vector<FCallbackEntry> callbacks;
};
