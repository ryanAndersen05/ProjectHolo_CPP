#include "core/EHGameInstance.h"
#include "animation/EHAnimatorComponent.h"
#include "factory/EHActorComponentFactory.h"
#include "hitbox/EHHitboxComponent.h"
#include "gamemode/EHGameModeTraining.h"
#include "gamemode/EHGameModeReplay.h"
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

    json Box(const std::string& name, EHitboxType type, const FVector& position, const FVector& size, bool active = true) {
        return {{"name", name}, {"type", type}, {"position", position}, {"size", size}, {"active", active}};
    }

    EHHitboxComponent& AttachBoxes(EHActor& actor, const json& definitions) {
        const json data = {{"hitboxes", definitions}};
        actor.AddComponent(FName("hitbox"), new EHHitboxComponent(data.get<EHHitboxComponent>()));
        return Hitboxes(actor);
    }

    void CheckOverlap(EHHitboxComponent& source, const EHHitboxComponent* target, bool expected,
        const FVector& expectedPosition = FVector::Zero) {
        const FVector sentinel(-1234.f, -5678.f);
        FVector position = sentinel;
        Check(source.DoesHitboxComponentOverlap(target, position) == expected, "Unexpected overlap result");
        CheckVector(position, expected ? expectedPosition : sentinel,
            expected ? "Wrong intersection center" : "Failed check changed the output position");
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

    void TestRectOverlaps() {
        const auto check = [](const FRect& first, const FRect& second, bool expected,
            const FVector& expectedCenter = FVector::Zero) {
            Check(first.IsOverlapping(second) == expected, "Wrong boolean rectangle overlap");
            Check(second.IsOverlapping(first) == expected, "Wrong reverse boolean rectangle overlap");

            const FVector sentinel(-1234.f, -5678.f);
            FVector center = sentinel;
            Check(first.IsOverlapping(second, center) == expected, "Wrong rectangle overlap with center");
            CheckVector(center, expected ? expectedCenter : sentinel, "Wrong rectangle intersection output");
            center = sentinel;
            Check(second.IsOverlapping(first, center) == expected, "Wrong reverse rectangle overlap with center");
            CheckVector(center, expected ? expectedCenter : sentinel, "Wrong reverse rectangle intersection output");
        };

        const FRect rectangle(FVector::Zero, FVector(4, 4));
        check(rectangle, FRect(FVector(2, 1), FVector(4, 2)), true, FVector(3, 2));
        check(rectangle, FRect(FVector(1, 1), FVector(1, 2)), true, FVector(1.5f, 2));
        check(rectangle, rectangle, true, FVector(2, 2));
        check(rectangle, FRect(FVector(5, 0), FVector(2, 2)), false);
        check(rectangle, FRect(FVector(4, 0), FVector(2, 2)), false);
        check(rectangle, FRect(FVector(4, 4), FVector(2, 2)), false);
        check(rectangle, FRect(FVector(1, 1), FVector(0, 2)), false);
        check(rectangle, FRect(FVector(1, 1), FVector(2, 0)), false);
        check(rectangle, FRect(FVector(1, 1), FVector::Zero), false);
        check(rectangle, FRect(), false);
        check(FRect(), FRect(), false);
    }

    void TestValidation() {
        const FName attack("attack");
        const FName missing("missing");
        const json data = ComponentData();
        auto boxes = data.get<EHHitboxComponent>();
        Check(boxes.GetType(attack) == EHitboxType::Hitbox, "Wrong attack type");
        Check(boxes.GetType(FName("body")) == EHitboxType::Hurtbox, "Wrong hurtbox type");
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

    void TestOverlapTypes() {
        const EHitboxType types[] = {EHitboxType::Hitbox, EHitboxType::Hurtbox};
        for (EHitboxType sourceType : types) {
            for (EHitboxType targetType : types) {
                EHActor sourceActor;
                EHActor targetActor;
                auto& source = AttachBoxes(sourceActor, json::array({
                    Box("source", sourceType, FVector::Zero, FVector(2, 2))}));
                auto& target = AttachBoxes(targetActor, json::array({
                    Box("target", targetType, FVector(1, 1), FVector(2, 2))}));
                const bool allowed = sourceType == EHitboxType::Hitbox && targetType == EHitboxType::Hurtbox;
                CheckOverlap(source, &target, allowed, FVector(1.5f, 1.5f));
            }
        }
    }

    void TestOverlapGeometry() {
        const FName attack("attack");
        const FName body("body");
        EHActor sourceActor;
        EHActor targetActor;
        auto& source = AttachBoxes(sourceActor, json::array({
            Box("attack", EHitboxType::Hitbox, FVector(1, 2), FVector(3, 4))}));
        auto& target = AttachBoxes(targetActor, json::array({
            Box("body", EHitboxType::Hurtbox, FVector(2, 3), FVector(4, 2))}));
        auto unattached = ComponentData().get<EHHitboxComponent>();
        EHActor emptyActor;
        auto& empty = AttachBoxes(emptyActor, json::array());
        CheckOverlap(source, nullptr, false);
        CheckOverlap(source, &source, false);
        CheckOverlap(source, &unattached, false);
        CheckOverlap(unattached, &target, false);
        CheckOverlap(source, &empty, false);
        CheckOverlap(empty, &target, false);
        CheckOverlap(source, &target, true, FVector(3, 4));
        CheckOverlap(source, &target, false);

        source.ResetOverlappingComponents();
        sourceActor.SetPosition(FVector(10, 20));
        sourceActor.SetScale(FVector(-2, 3));
        Check(target.SetBounds(body, FVector(4, 30), FVector(8, 4)), "Target bounds update failed");
        CheckOverlap(source, &target, true, FVector(6, 32));
        source.ResetOverlappingComponents();
        sourceActor.SetPosition(FVector(30, 40));
        CheckOverlap(source, &target, false);
        sourceActor.SetPosition(FVector(10, 20));
        targetActor.SetPosition(FVector(20, 40));
        targetActor.SetScale(FVector(-2, -1));
        Check(target.SetBounds(body, FVector(4, 6), FVector(4, 4)), "Target bounds update failed");
        CheckOverlap(source, &target, true, FVector(6, 32));
        source.ResetOverlappingComponents();
        Check(source.SetPosition(attack, FVector(100, 100)), "Attack position update failed");
        CheckOverlap(source, &target, false);
        Check(source.SetPosition(attack, FVector(1, 2)), "Attack position update failed");
        CheckOverlap(source, &target, true, FVector(6, 32));

        source.ResetOverlappingComponents();
        sourceActor.SetPosition(FVector::Zero);
        sourceActor.SetScale(FVector::One);
        targetActor.SetPosition(FVector::Zero);
        targetActor.SetScale(FVector::One);
        Check(source.SetBounds(attack, FVector::Zero, FVector(2, 2)), "Attack bounds update failed");
        Check(target.SetBounds(body, FVector(2, 0), FVector(2, 2)), "Target bounds update failed");
        CheckOverlap(source, &target, false); // Touching edges.
        Check(target.SetPosition(body, FVector(2, 2)), "Target position update failed");
        CheckOverlap(source, &target, false); // Touching corners.
        Check(target.SetBounds(body, FVector(1, 1), FVector(0, 1)), "Target bounds update failed");
        CheckOverlap(source, &target, false); // A line inside the attack has no area.
        Check(target.SetSize(body, FVector(1, 0)), "Target size update failed");
        CheckOverlap(source, &target, false);
        Check(target.SetBounds(body, FVector::Zero, FVector(2, 2)), "Target bounds update failed");
        Check(source.SetSize(attack, FVector(0, 1)), "Attack size update failed");
        CheckOverlap(source, &target, false);
        Check(source.SetSize(attack, FVector(2, 2)), "Attack size update failed");
        sourceActor.SetScale(FVector::Zero);
        CheckOverlap(source, &target, false);
    }

    void TestActiveListsAndHistory() {
        const FName first("first");
        const FName second("second");
        const FName body("body");
        const json definitions = json::array({
            Box("first", EHitboxType::Hitbox, FVector::Zero, FVector(2, 2)),
            Box("second", EHitboxType::Hitbox, FVector(10, 0), FVector(2, 2))});
        const json targetDefinitions = json::array({
            Box("body", EHitboxType::Hurtbox, FVector::Zero, FVector(20, 2))});
        EHActor sourceActor;
        EHActor targetActor;
        EHActor anotherTargetActor;
        auto& source = AttachBoxes(sourceActor, definitions);
        auto& target = AttachBoxes(targetActor, targetDefinitions);
        auto& anotherTarget = AttachBoxes(anotherTargetActor, targetDefinitions);
        CheckOverlap(source, &target, true, FVector(1, 1)); // Prefab order wins.
        CheckOverlap(source, &target, false); // Both attacks share component history.
        CheckOverlap(source, &anotherTarget, true, FVector(1, 1));
        source.ResetOverlappingComponents();

        Check(source.SetActive(first, true) && source.SetActive(first, true), "Repeated activation failed");
        Check(source.SetActive(first, false) && source.SetActive(first, false), "Repeated deactivation failed");
        CheckOverlap(source, &target, true, FVector(11, 1)); // No stale first attack.
        source.ResetOverlappingComponents();
        Check(source.SetActive(first, true), "Reactivation failed");
        CheckOverlap(source, &target, true, FVector(11, 1)); // Reactivation appends after second.
        source.ResetOverlappingComponents();
        Check(source.SetActive(second, false), "Deactivation failed");
        CheckOverlap(source, &target, true, FVector(1, 1));

        Check(source.SetActive(first, false) && source.SetActive(first, true), "Attack toggle failed");
        Check(target.SetActive(body, false) && target.SetActive(body, true), "Hurtbox toggle failed");
        CheckOverlap(source, &target, false); // Toggling must not reset hit history.
        source.ResetOverlappingComponents();
        Check(source.SetActive(first, false), "Deactivation failed");
        CheckOverlap(source, &target, false); // No active attacks.
        Check(source.SetActive(first, true), "Activation failed");
        Check(target.SetActive(body, false), "Hurtbox deactivation failed");
        CheckOverlap(source, &target, false);
        Check(target.SetActive(body, true), "Hurtbox activation failed");
        CheckOverlap(source, &target, true, FVector(1, 1));

        json replacement = {{"hitboxes", definitions}};
        replacement["hitboxes"][0]["active"] = false;
        replacement["hitboxes"][1]["type"] = "unknown";
        bool rejected = false;
        try {
            replacement.get_to(source);
        }
        catch (const std::exception&) {
            rejected = true;
        }
        Check(rejected, "Invalid replacement was accepted");
        Check(source.IsActive(first) == true && source.IsActive(second) == false, "Rejected load changed activation");
        CheckOverlap(source, &target, false); // Rejected loads preserve history as well.
        source.ResetOverlappingComponents();
        CheckOverlap(source, &target, true, FVector(1, 1)); // Active index also survived.

        replacement["hitboxes"][1]["type"] = "Hitbox";
        replacement.get_to(source);
        CheckOverlap(source, &target, false); // Definition reloads do not reset history.
        source.ResetOverlappingComponents();
        CheckOverlap(source, &target, true, FVector(11, 1)); // Rebuild excludes old first entry.
        const json empty = {{"hitboxes", json::array()}};
        empty.get_to(source);
        source.ResetOverlappingComponents();
        CheckOverlap(source, &target, false);
    }

    void TestDrawCommands() {
        EHGameModeTraining training;
        EHGameModeFighting fighting;
        EHGameModeReplay replay;
        EHGameMode normal;
        EHActor actor;
        auto& boxes = AttachBoxes(actor, json::array({
            Box("attack", EHitboxType::Hitbox, FVector(1, 2), FVector(3, 4)),
            Box("body", EHitboxType::Hurtbox, FVector::Zero, FVector(2, 2)),
            Box("inactive", EHitboxType::Hitbox, FVector::Zero, FVector(2, 2), false),
            Box("empty", EHitboxType::Hitbox, FVector::Zero, FVector::Zero)}));
        actor.SetPosition(FVector(10, 20));
        actor.SetScale(FVector(-2, 3));
        FRenderQueue queue;
        for (const EHGameMode* mode : {static_cast<const EHGameMode*>(nullptr),
                static_cast<const EHGameMode*>(&normal), static_cast<const EHGameMode*>(&fighting), static_cast<const EHGameMode*>(&replay)}) {
            actor.DisplayActor(queue, FRenderContext{mode});
            Check((queue.sprites.empty() && queue.debugRectangles.empty()), "Hitboxes rendered outside training mode");
        }
        actor.DisplayActor(queue, FRenderContext{&training});
        Check(queue.debugRectangles.size() == 2, "Expected one command per active nonempty box");
        bool foundAttack = false;
        bool foundBody = false;
        Check(queue.sprites.empty(), "Hitboxes unexpectedly emitted sprite commands");
        for (const auto& command : queue.debugRectangles) {
            const auto* rectangle = &command;
            if (rectangle->outlineColor.r == 255) {
                foundAttack = true;
                CheckBounds(rectangle->bounds, FVector(2, 26), FVector(6, 12));
            } else {
                foundBody = true;
                CheckBounds(rectangle->bounds, FVector(6, 20), FVector(4, 6));
            }
        }
        Check(foundAttack && foundBody, "Missing attack or hurtbox visualization");
        Check(boxes.IsActive(FName("inactive")) == false, "Rendering changed activation");
        boxes.SetActive(FName("attack"), false);
        queue.debugRectangles.clear();
        actor.DisplayActor(queue, FRenderContext{&training});
        Check(queue.debugRectangles.size() == 1, "Deactivated attack remained visible");
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
        CheckBounds(firstBoxes.GetLocalBounds(attack), FVector(1, 2), FVector(3, 4));
        Check(firstBoxes.IsActive(attack) == false, "Lua binding checks did not restore activation");
        auto* alternate = dynamic_cast<EHHitboxComponent*>(first->GetActorComponent(FName("alternate")));
        Check(alternate && alternate->IsActive(attack) == false, "Activation leaked to an alternate component");
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
        Check(firstBoxes.SetBounds(FName("body"), FVector(3, 4), FVector(2, 2)), "Hurtbox setup failed");
        CheckOverlap(secondBoxes, &firstBoxes, true, FVector(4, 5));
        second->TickActor(1.f);
        Check(secondBoxes.IsActive(attack) == true, "Engine performed unwanted automatic cleanup");
        CheckOverlap(secondBoxes, &firstBoxes, false); // Animation transition preserves history.

        sol::protected_function resetHistory = states["ResetHitHistory"];
        sol::protected_function_result resetResult = resetHistory(second);
        if (!resetResult.valid()) {
            const sol::error error = resetResult;
            throw std::runtime_error(error.what());
        }
        Check(secondBoxes.IsActive(attack) == true && secondBoxes.IsActive(FName("body")) == true,
            "Lua reset changed activation");
        CheckBounds(secondBoxes.GetLocalBounds(attack), FVector(2, 3), FVector(4, 5));
        CheckOverlap(secondBoxes, &firstBoxes, true, FVector(4, 5));
    }
}

int main() {
    try {
        TestRectOverlaps();
        TestValidation();
        TestTransforms();
        TestOverlapTypes();
        TestOverlapGeometry();
        TestActiveListsAndHistory();
        TestDrawCommands();
        EHGameInstance instance;
        TestLuaAndAnimation(instance);
        std::cout << "Hitbox validation, overlaps, activation, Lua reset, and animation smoke checks passed\n";
        return 0;
    }
    catch (const std::exception& error) {
        std::cerr << "Hitbox smoke checks failed: " << error.what() << '\n';
        return 1;
    }
}
