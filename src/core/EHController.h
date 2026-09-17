#pragma once
#include <array>
#include <cstdint>
#include "core/EHActor.h"


enum class EButton : uint8_t
{
    None = 0x00,
    Up = 0x01,
    Down = 0x02,
    Right = 0x04,
    Left = 0x08,

    Light = 0x10,
    Medium = 0x20,
    Heavy = 0x40,
    Special = 0x80,

    FaceButtons = 0xf0,
    AllButtons = 0xff,
};

inline EButton operator|(EButton b1, EButton b2) {
    return static_cast<EButton>(static_cast<uint8_t>(b1) | static_cast<uint8_t>(b2));
}

inline EButton operator&(EButton b1, EButton b2) {
    return static_cast<EButton>(static_cast<uint8_t>(b1) & static_cast<uint8_t>(b2));
}

inline EButton operator^(EButton b1, EButton b2) {
    return static_cast<EButton>(static_cast<uint8_t>(b1) ^ static_cast<uint8_t>(b2));
}

inline EButton operator~(EButton b1) {
    return static_cast<EButton>(~static_cast<uint8_t>(b1));
}

inline EButton& operator|=(EButton& b1, EButton b2) {
    return b1 = b1 | b2;
}

inline EButton& operator&=(EButton& b1, EButton b2) {
    return b1 = b1 & b2;
}

inline EButton& operator^=(EButton& b1, EButton b2) {
    return b1 = b1 ^ b2;
}

class EHController : public EHActor
{
private:
    static constexpr int ButtonLength = 100000;
    std::array<EButton, ButtonLength> inputHistory{};

public:
    EHDelegate<EButton, bool, int> OnInputUpdatedEvent;

    EHController();
    ~EHController() override = default;
    void AssignButton(EButton button, int frame);
    [[nodiscard]] EButton GetButtonAtFrame(int frame) const;
    virtual void TickController(int frame);

    [[nodiscard]] int GetHorizontalAxis(int frame) const;
    [[nodiscard]] int GetVerticalAxis(int frame) const;
};