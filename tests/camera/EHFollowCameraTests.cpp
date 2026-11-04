#include "camera/EHFollowCamera.h"
#include "gamemode/EHGameModeFighting.h"
#include "core/EHGameInstance.h"
#include "physics/EHPhyicsComponent.h"
#include "factory/EHActorFactory.h"
#include <cmath>
#include <iostream>
#include <stdexcept>

namespace {
    void Check(bool condition, const char* message) {
        if (!condition) throw std::runtime_error(message);
    }
    void Position(const EHActor& actor, float x, float y) {
        const FVector actual = actor.GetPosition();
        Check(std::abs(actual.x - x) < 0.0001f && std::abs(actual.y - y) < 0.0001f,
            "Unexpected follow camera position");
    }
    void TestFollowing() {
        EHCameraFollow camera;
        camera.SetFollowSpeed(0.f); // Test target calculation independently of smoothing.
        Check(camera.GetMainCamera() == nullptr, "Unattached camera accessor returned garbage");
        camera.InitializeActor(json::array({{{"componentType", "camera"}, {"componentName", "camera"},
            {"data", {{"offset", FVector::Zero}, {"cameraSize", 20}}}}}));
        Check(camera.GetIsLateTickable(), "Follow actor was not registered for late ticking");
        camera.SetPosition(FVector(7, 2));
        camera.LateTickActor(0.016f);
        Position(camera, 7, 2);
        EHActor first, second, third;
        first.SetPosition(FVector(-3, 2));
        second.SetPosition(FVector(5, 4));
        camera.AddTargetActor(nullptr);
        camera.AddTargetActor(&camera);
        camera.AddTargetActor(&first);
        camera.AddTargetActor(&first);
        camera.AddTargetActor(&second);
        camera.LateTickActor(0.016f);
        Position(camera, 1, 0);
        second.SetPosition(FVector(5, 5));
        camera.LateTickActor(0.016f);
        Position(camera, 1, 0);
        second.SetPosition(FVector(5, 5.25f));
        camera.LateTickActor(0.016f);
        Position(camera, 1, 0.25f);
        first.SetPosition(FVector(-3, 8));
        camera.LateTickActor(0.016f);
        Position(camera, 1, 3);
        camera.SetHeightThreshold(7);
        camera.LateTickActor(0.016f);
        Position(camera, 1, 1);
        third.SetPosition(FVector(10, 9));
        camera.AddTargetActor(&third);
        camera.LateTickActor(0.016f);
        Position(camera, 4, 2);
        third.SetIsActive(false);
        camera.LateTickActor(0.016f);
        Position(camera, 1, 1);
        camera.RemoveTargetActor(&first);
        camera.LateTickActor(0.016f);
        Position(camera, 5, 0);
        camera.RemoveTargetActor(&second);
        camera.LateTickActor(0.016f);
        Position(camera, 5, 0); // No active targets retain the last position.
        camera.RemoveTargetActor(&third);
        camera.RemoveTargetActor(&third);
        camera.SetHeightThreshold(-1);
        Check(camera.GetHeightThreshold() == 0.f, "Negative threshold was not clamped");
        Check(camera.GetMainCamera() != nullptr, "Camera component accessor failed");
    }
    void TestGameModePhase() {
        EHGameInstance instance;
        EHGameModeFighting mode;
        auto* camera = dynamic_cast<EHCameraFollow*>(mode.CreateActor(FName("camera")));
        Check(camera != nullptr, "Factory did not create follow camera");
        camera->SetFollowSpeed(0.f);
        // A second follow actor can act as a moving target without any character assets.
        EHActor* target = mode.CreateActor(FName("moving_camera"));
        auto* physics = dynamic_cast<EHPhysicsComponent*>(target->GetActorComponent(FName("physics")));
        physics->SetVelocity(FVector(4, 6));
        camera->AddTargetActor(target);
        mode.TickGameMode(1.f);
        Position(*target, 4, 6);
        Position(*camera, 4, 1); // Must use the post-physics position this same step.
    }
    void TestSmoothing() {
        EHActor target;
        target.SetPosition(FVector(10, 9));
        EHCameraFollow camera;
        camera.AddTargetActor(&target);
        camera.LateTick(0.f);
        Position(camera, 0, 0);
        camera.LateTick(1.f / 60.f);
        const FVector firstStep = camera.GetPosition();
        Check(firstStep.x > 0.f && firstStep.x < 10.f && firstStep.y > 0.f && firstStep.y < 4.f,
            "Camera snapped or overshot instead of smoothing both axes");
        camera.LateTick(2.f);
        Position(camera, 10, 4); // A long step approaches the target without overshooting.

        EHCameraFollow sixtyHz, thirtyHz;
        sixtyHz.AddTargetActor(&target);
        thirtyHz.AddTargetActor(&target);
        for (int i = 0; i < 12; ++i) sixtyHz.LateTick(1.f / 60.f);
        for (int i = 0; i < 6; ++i) thirtyHz.LateTick(1.f / 30.f);
        const FVector atSixtyHz = sixtyHz.GetPosition();
        Position(thirtyHz, atSixtyHz.x, atSixtyHz.y);

        camera.SetFollowSpeed(0.f);
        target.SetPosition(FVector(-5, 2));
        camera.LateTick(1.f / 60.f);
        Position(camera, -5, 0);
        camera.SetFollowSpeed(-1.f);
        Check(camera.GetFollowSpeed() == 0.f, "Negative follow speed was not clamped");
    }
}
int main() {
    try {
        TestFollowing();
        TestSmoothing();
        TestGameModePhase();
        std::cout << "Follow camera checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
