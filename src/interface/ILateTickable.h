#pragma once

class ILateTickable
{
public:
    virtual void LateTick(float deltaTime) = 0;
};