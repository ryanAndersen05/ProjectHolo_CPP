#include "core/EHGameInstance.h"
#include "animation/EHAnimatorComponent.h"
#include "factory/EHActorComponentFactory.h"
#include "hitbox/EHHitboxComponent.h"
#include <cmath>
#include <fstream>
#include <iostream>
#include <limits>
#include <stdexcept>

namespace {
    void Check(bool condition, const std::string& message) {
        if (!condition) throw std::runtime_error(message);
    }

    void CheckVector(const FVector& actual, const FVector& expected, const std::string& message) {
        Check(std::abs(actual.x - expected.x) < 0.0001f
            && std::abs(actual.y - expected.y) < 0.0001f, message);
    }

    void CheckBounds(const std::optional<FRect>& bounds, const FVector& position, const FVector& size) {
        Check(bounds.has_value(), "Expected bounds to exist");
        CheckVector(bounds->GetPosition(), position, "Unexpected bottom-left position");
        CheckVector(bounds->GetSize(), size, "Unexpected size");
        Check(bounds->IsPointInsideRect(position + size * 0.5f), "Rectangle extrema are stale");
    }

    json ComponentData() {
        std::ifstream file("assets/prefabs/hitboxActor.json");
        Check(file.is_open(), "Missing hitbox prefab fixture");
        const json prefab = json::parse(file);
        return prefab.at("components").at(0).at("data");
    }

    EHHitboxComponent& Hitboxes(EHActor& actor) {
        auto* component = dynamic_cast<EHHitboxComponent*>(
            actor.GetActorComponent(EHActorComponentFactory::HitboxComponentId));
        Check(component != nullptr, "Factory did not attach the hitbox component");
        return *component;
    }

    EHAnimatorComponent& Animator(EHActor& actor) {
        auto* component = dynamic_cast<EHAnimatorComponent*>(
            actor.GetActorComponent(EHActorComponentFactory::AnimatorComponentId));
        Check(component != nullptr, "Missing animator component");
        return *component;
    }

    void CheckRejectedJson(EHHitboxComponent& boxes, const json& invalid) {
        bool rejected = false;
        try {
            invalid.get_to(boxes);
        }
        catch (const std::exception&) {
            rejected = true;
        }
        Check(rejected, "Invalid prefab definition was accepted");
        CheckBounds(boxes.GetLocalBounds(FName("attack")), FVector(1, 2), FVector(3, 4));
        Check(boxes.IsActive(FName("body")) == true, "Rejected load changed existing state");
    }

    void TestValidation() {
        const FName attack("attack");
        const FName missing("missing");
        const json data = ComponentData();
        auto boxes = data.get<EHHitboxComponent>();
        Check(boxes.GetType(attack) == EHHitboxType::Hitbox, "Wrong attack type");
        Check(boxes.GetType(FName("body")) == EHHitboxType::Hurtbox, "Wrong hurtbox type");
        Check(boxes.IsActive(attack) == false, "Activation should default to false");
        Check(!boxes.GetWorldBounds(attack), "Unattached component must not return world bounds");
        Check(!boxes.HasHitbox(missing) && !boxes.GetType(missing) && !boxes.IsActive(missing)
            && !boxes.GetPosition(missing) && !boxes.GetSize(missing)
            && !boxes.GetLocalBounds(missing) && !boxes.GetWorldBounds(missing), "Missing-name query succeeded");
        Check(!boxes.SetActive(missing, true) && !boxes.SetPosition(missing, FVector(1, 2))
            && !boxes.SetSize(missing, FVector(3, 4))
            && !boxes.SetBounds(missing, FVector(1, 2), FVector(3, 4)), "Missing-name update succeeded");

        const float infinity = std::numeric_limits<float>::infinity();
        const float nan = std::numeric_limits<float>::quiet_NaN();
        const float maximum = std::numeric_limits<float>::max();
        Check(!boxes.SetPosition(attack, FVector(infinity, 0)), "Infinite position was accepted");
        Check(!boxes.SetSize(attack, FVector(0, nan)), "NaN size was accepted");
        Check(!boxes.SetSize(attack, FVector(-1, 4)), "Negative size was accepted");
        Check(!boxes.SetBounds(attack, FVector(maximum, 0), FVector(maximum, 1)), "Overflowing bounds were accepted");
        CheckBounds(boxes.GetLocalBounds(attack), FVector(1, 2), FVector(3, 4));

        json invalid = data;
        invalid["hitboxes"][0]["name"] = "";
        CheckRejectedJson(boxes, invalid);
        invalid = data;
        invalid["hitboxes"].push_back(invalid["hitboxes"][0]);
        CheckRejectedJson(boxes, invalid);
        invalid = data;
        invalid["hitboxes"][0]["type"] = "unknown";
        CheckRejectedJson(boxes, invalid);
        invalid = data;
        invalid["hitboxes"][0]["size"]["x"] = -1;
        CheckRejectedJson(boxes, invalid);
        invalid = data;
        invalid["hitboxes"][0]["position"]["y"] = infinity;
        CheckRejectedJson(boxes, invalid);
        invalid = data;
        invalid["hitboxes"][0]["active"] = "true";
        CheckRejectedJson(boxes, invalid);
        invalid = data;
        invalid["hitboxes"] = json::object();
        CheckRejectedJson(boxes, invalid);
        invalid = data;
        invalid["hitboxes"][0].erase("size");
        CheckRejectedJson(boxes, invalid);

        Check(boxes.SetSize(attack, FVector::Zero), "Zero size was rejected");
        CheckBounds(boxes.GetLocalBounds(attack), FVector(1, 2), FVector::Zero);
        const auto empty = json{{"hitboxes", json::array()}}.get<EHHitboxComponent>();
        Check(!empty.HasHitbox(attack), "Empty definition should contain no hitboxes");
    }

    void TestTransforms() {
        EHActor actor;
        actor.AddComponent(FName("hitbox"), new EHHitboxComponent(ComponentData().get<EHHitboxComponent>()));
        auto& boxes = Hitboxes(actor);
        const FName attack("attack");
        actor.SetPosition(FVector(10, 20));
        actor.SetScale(FVector(2, 3));
        CheckBounds(boxes.GetWorldBounds(attack), FVector(12, 26), FVector(6, 12));
        actor.SetScale(FVector(-2, 3));
        CheckBounds(boxes.GetWorldBounds(attack), FVector(2, 26), FVector(6, 12));
        actor.SetScale(FVector(-2, -3));
        CheckBounds(boxes.GetWorldBounds(attack), FVector(2, 2), FVector(6, 12));
        actor.SetRotation(75.f);
        CheckBounds(boxes.GetWorldBounds(attack), FVector(2, 2), FVector(6, 12));
        actor.SetPosition(FVector(20, 30));
        CheckBounds(boxes.GetWorldBounds(attack), FVector(12, 12), FVector(6, 12));
        actor.SetScale(FVector::Zero);
        CheckBounds(boxes.GetWorldBounds(attack), FVector(20, 30), FVector::Zero);
        CheckBounds(boxes.GetLocalBounds(attack), FVector(1, 2), FVector(3, 4));

        Check(boxes.SetPosition(attack, FVector(-2, -3)), "Position update failed");
        Check(boxes.SetSize(attack, FVector(8, 9)), "Size update failed");
        CheckBounds(boxes.GetLocalBounds(attack), FVector(-2, -3), FVector(8, 9));
        Check(!boxes.GetLocalBounds(attack)->IsPointInsideRect(FVector(7, 7)), "Size update retained old extrema");
    }

    void TestLuaAndAnimation(EHGameInstance& instance) {
        EHGameMode mode;
        EHActor* first = mode.CreateActor(FName("hitbox_test_actor"));
        EHActor* second = mode.CreateActor(FName("hitbox_test_actor"));
        Check(first && second, "Prefab actor creation failed");
        auto& firstBoxes = Hitboxes(*first);
        auto& secondBoxes = Hitboxes(*second);
        CheckBounds(firstBoxes.GetLocalBounds(FName("body")), FVector(-0.5f, 0.25f), FVector(1, 2));
        CheckBounds(secondBoxes.GetLocalBounds(FName("body")), FVector(-0.5f, 0.25f), FVector(1, 2));
        first->AddComponent(FName("alternate"), new EHHitboxComponent(ComponentData().get<EHHitboxComponent>()));

        sol::table states = instance.GetLuaScriptSystem()->GetTable(FName("hitbox_test_states"));
        Check(states.valid(), "Lua state fixture did not load");
        sol::protected_function checkBindings = states["CheckBindings"];
        EHActor emptyActor;
        sol::protected_function_result result = checkBindings(first, &emptyActor);
        if (!result.valid()) {
            const sol::error error = result;
            throw std::runtime_error(error.what());
        }

        const FName attack("attack");
        first->TickActor(1.f);
        Check(firstBoxes.IsActive(attack) == false, "Hitbox activated before its Lua frame");
        first->TickActor(1.f);
        Check(firstBoxes.IsActive(attack) == true, "Lua frame did not activate the hitbox");
        CheckBounds(firstBoxes.GetLocalBounds(attack), FVector(2, 3), FVector(4, 5));
        Check(secondBoxes.IsActive(attack) == false, "Activation leaked between actor instances");
        CheckBounds(secondBoxes.GetLocalBounds(attack), FVector(1, 2), FVector(3, 4));
        first->TickActor(1.f);
        CheckBounds(firstBoxes.GetLocalBounds(attack), FVector(6, 7), FVector(8, 9));
        first->TickActor(1.f);
        Check(firstBoxes.IsActive(attack) == false, "Lua onExit did not deactivate the hitbox");
        Check(firstBoxes.IsActive(FName("body")) == true, "Attack cleanup disabled the hurtbox");

        second->TickActor(1.f);
        second->TickActor(1.f);
        Check(secondBoxes.IsActive(attack) == true, "Second actor did not activate independently");
        Animator(*second).SetCurrentState(FName("done"));
        Check(secondBoxes.IsActive(attack) == false, "Interrupted animation did not run Lua cleanup");
        Animator(*second).SetCurrentState(FName("persistent"));
        Check(secondBoxes.IsActive(attack) == true, "Lua onEnter did not activate the hitbox");
        second->TickActor(1.f);
        Check(secondBoxes.IsActive(attack) == true, "Engine performed unwanted automatic cleanup");
    }
}

int main() {
    try {
        TestValidation();
        TestTransforms();
        EHGameInstance instance;
        TestLuaAndAnimation(instance);
        std::cout << "Hitbox validation, transforms, Lua bindings, and animation smoke checks passed\n";
        return 0;
    }
    catch (const std::exception& error) {
        std::cerr << "Hitbox smoke checks failed: " << error.what() << '\n';
        return 1;
    }
}
