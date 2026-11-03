#include "camera/EHFollowCamera.h"
#include "core/EHGameMode.h"
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
    class EHLateProbe : public EHActorComponent, public ILateTickable {
    public:
        int calls = 0;
        float elapsed = 0.f;
        FVector observedPosition;
        void LateTick(float deltaTime) override {
            ++calls;
            elapsed = deltaTime;
            observedPosition = GetActorPosition();
        }
    };
    void TestFollowing() {
        EHCameraFollow camera;
        Check(camera.GetIsLateTickable(), "Follow actor was not registered for late ticking");
        Check(camera.GetMainCamera() == nullptr, "Unattached camera accessor returned garbage");
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
        auto* probe = new EHLateProbe();
        camera.AddComponent(FName("lateProbe"), probe);
        camera.SetTimeScale(0.5f);
        camera.LateTickActor(0.2f);
        Check(probe->calls == 1 && std::abs(probe->elapsed - 0.1f) < 0.0001f,
            "Actor late ticking disrupted component ticks or time scale");
        Check(probe->observedPosition.x == 1.f, "Component did not see the updated camera");
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
        auto* component = new EHCamera();
        camera.AddComponent(FName("camera"), component);
        Check(camera.GetMainCamera() == component, "Camera component accessor failed");
    }
    void TestGameModePhase() {
        EHGameInstance instance;
        EHGameMode mode;
        auto* camera = dynamic_cast<EHCameraFollow*>(mode.CreateActor(FName("camera")));
        Check(camera != nullptr, "Factory did not create follow camera");
        // A second follow actor can act as a moving target without any character assets.
        EHActor* target = mode.CreateActor(FName("camera"));
        auto* physics = new EHPhysicsComponent(json{
            {"useGravity", false}, {"gravityScale", 1},
            {"useTerminalVelocity", false}, {"terminalVelocity", 0}}.get<EHPhysicsComponent>());
        target->AddComponent(FName("physics"), physics);
        physics->SetVelocity(FVector(4, 6));
        camera->AddTargetActor(target);
        mode.TickGameMode(1.f);
        Position(*target, 4, 6);
        Position(*camera, 4, 1); // Must use the post-physics position this same step.
    }
}
int main() {
    try {
        TestFollowing();
        TestGameModePhase();
        std::cout << "Follow camera checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
