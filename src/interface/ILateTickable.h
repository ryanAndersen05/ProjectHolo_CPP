#pragma once

class ILateTickable
{
public:
    virtual void LateTick() = 0;
};