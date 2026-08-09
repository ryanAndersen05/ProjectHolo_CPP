#pragma once

class ITickable
{
public:
    virtual void Tick(float deltaTime) = 0;
};