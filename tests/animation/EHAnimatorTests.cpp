#include "animation/EHAnimatorComponent.h"
#include "core/EHActor.h"
#include "core/EHGameInstance.h"
#include <iostream>
#include <stdexcept>

namespace {
    void Check(bool condition, const char* message) {
        if (!condition) throw std::runtime_error(message);
    }
    EHAnimatorComponent& Attach(EHActor& actor, const char* asset) {
        actor.InitializeActor(json::array({{{"componentType", "animator"}, {"componentName", "animator"},
            {"data", {{"stateMachineAsset", asset}}}}}));
        return *dynamic_cast<EHAnimatorComponent*>(actor.GetActorComponent(FName("animator")));
    }
    void TestAnyState(EHGameInstance& instance) {
        EHActor actor;
        auto& animator = Attach(actor, "animator_any");
        sol::table states = instance.GetLuaScriptSystem()->GetTable(FName("animator_any"));
        sol::table calls = states["calls"];
        animator.Tick(0);
        Check(calls.get<std::string>("order") == "any,current,", "any_state did not run before current state");
        Check(calls.get<int>("currentFrame") == 0, "Initial frame was incorrect");
        animator.Tick(0);
        Check(calls.get<int>("currentFrame") == 1, "Normal ticks did not advance the frame");
        const FName overrideKey("override");
        animator.SetBool(overrideKey, true);
        animator.SetBool(FName("localChange"), true);
        animator.Tick(0);
        Check(calls.get<int>("current") == 2, "Current state tick ran after any_state selected a transition");
        Check(calls.get<int>("readyExit") == 1 && calls.get<int>("winnerEntry") == 1,
            "Global transition did not run normal exit/entry callbacks");
        Check(calls.get<int>("loserEntry") == 0, "Current state overrode the any_state result");
        Check(calls.get<int>("anyEntry") == 0 && calls.get<int>("anyExit") == 0,
            "any_state was entered as a playback state");
        animator.SetBool(overrideKey, false);
        animator.Tick(0);
        Check(calls.get<int>("winnerFrame") == 0, "Global transition did not reset the new state's frame");
        animator.Tick(0);
        Check(calls.get<int>("winnerFrame") == 1, "Winner did not advance normally");
    }
    void TestOptionalAnyState(EHGameInstance& instance, const char* asset) {
        EHActor actor;
        auto& animator = Attach(actor, asset);
        sol::table states = instance.GetLuaScriptSystem()->GetTable(FName(asset));
        sol::table calls = states["calls"];
        animator.Tick(0);
        animator.Tick(0);
        Check(calls.get<int>("current") == 2 && calls.get<int>("currentFrame") == 1,
            "Missing or empty any_state stopped normal playback");
    }
}
int main() {
    try {
        EHGameInstance instance;
        TestAnyState(instance);
        TestOptionalAnyState(instance, "animator_without_any");
        TestOptionalAnyState(instance, "animator_empty_any");
        std::cout << "Native animator any_state checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
