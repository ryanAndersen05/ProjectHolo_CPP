#pragma once
#include <cstdint>


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

    Face = 0xf0,
    All = 0xff,
};

class EHController
{
private:
    static constexpr int ButtonLength = 100000;
    EButton inputHistory[ButtonLength];

public:
    void AssignButton(EButton button, int frame);
    void TickController();
};