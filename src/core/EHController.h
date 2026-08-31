#pragma once
#include <array>
#include <cstdint>


enum EButton : uint8_t
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

class EHController
{
private:
    static constexpr int ButtonLength = 100000;
    std::array<EButton, ButtonLength> inputHistory{};

public:
    EHController();
    virtual ~EHController() = default;
    void AssignButton(EButton button, int frame);
    virtual void TickController() {}
};