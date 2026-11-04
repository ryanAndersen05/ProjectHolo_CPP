#pragma once
#include <vector>
class EHActor;
class EHWorld;

class EHPhysicsSystem {
public:
    // Run once after all movement/animation ticks and before late ticks.
    static void Step(const std::vector<EHActor*>& actors, float deltaTime, const EHWorld* world = nullptr);
};
