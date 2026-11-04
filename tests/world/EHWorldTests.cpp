#include "world/EHWorld.h"
#include "world/EHParallaxStage.h"
#include "character/EHCharacter.h"
#include "physics/EHPhysicsSystem.h"
#include "physics/EHPhyicsComponent.h"
#include "physics/EHBoxColliderComponent.h"
#include "factory/EHActorFactory.h"
#include "core/EHGameInstance.h"
#include "gamemode/EHGameModeFighting.h"
#include "gamemode/EHGameModeTraining.h"
#include "camera/EHFollowCamera.h"
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <limits>
#include <memory>
#include <stdexcept>

namespace {
    void Check(bool condition, const char* message) {
        if (!condition) throw std::runtime_error(message);
    }
    void Near(float actual, float expected) {
        if (!std::isfinite(actual) || std::abs(actual - expected) > 0.0001f)
            throw std::runtime_error("Expected " + std::to_string(expected) + ", got " + std::to_string(actual));
    }
    json WorldData() {
        return {{"worldSize", 15}, {"spawnPoints", json::array({FVector(-3, 0), FVector(3, 0)})}};
    }
    json BodyComponents(bool collider = true) {
        json result = json::array({{{"componentType", "physics"}, {"componentName", "physics"},
            {"data", {{"useGravity", false}, {"gravityScale", 1},
                      {"useTerminalVelocity", false}, {"terminalVelocity", 10}}}}});
        if (collider) result.push_back({{"componentType", "boxcollider"}, {"componentName", "boxcollider"},
            {"data", {{"size", FVector(2, 4)}, {"offset", FVector::Zero}}}});
        return result;
    }
    struct FFighter {
        EHCharacter actor;
        EHPhysicsComponent* physics;
        EHBoxColliderComponent* collider;
        FFighter(float x, float vx, float y = 0.f) {
            actor.InitializeActor(BodyComponents());
            physics = dynamic_cast<EHPhysicsComponent*>(actor.GetActorComponent(FName("physics")));
            collider = dynamic_cast<EHBoxColliderComponent*>(actor.GetActorComponent(FName("boxcollider")));
            actor.SetPosition(FVector(x, y));
            physics->SetVelocity(FVector(vx, 0));
        }
    };
    void TestConfiguration() {
        auto world = WorldData().get<EHWorld>();
        Near(world.GetMinX(), -7.5f);
        Near(world.GetMaxX(), 7.5f);
        Near(world.GetSpawnPoint(0)->x, -3);
        Near(world.GetSpawnPoint(1)->x, 3);
        Check(!world.GetSpawnPoint(2), "Missing spawn point was returned");
        const FVector clamped = world.ClampPosition(FVector(10, 6));
        Near(clamped.x, 7.5f);
        Near(clamped.y, 6);
        for (int invalidCase = 0; invalidCase < 7; ++invalidCase) {
            json invalid = WorldData();
            if (invalidCase == 0) invalid["worldSize"] = 0;
            if (invalidCase == 1) invalid["worldSize"] = -15;
            if (invalidCase == 2) invalid["worldSize"] = std::numeric_limits<float>::infinity();
            if (invalidCase == 3) invalid["spawnPoints"][0]["x"] = -8;
            if (invalidCase == 4) invalid["spawnPoints"][0]["y"] = -1;
            if (invalidCase == 5) invalid["spawnPoints"] = json::object();
            if (invalidCase == 6) invalid.erase("spawnPoints");
            bool rejected = false;
            try { invalid.get_to(world); } catch (const std::exception&) { rejected = true; }
            Check(rejected, "Invalid world definition was accepted");
            Near(world.GetWorldSize(), 15);
            Near(world.GetSpawnPoint(0)->x, -3);
        }
        json parallax = {{"backgroundLayers", json::array()}};
        std::unique_ptr<EHActor> actor(EHActorFactory::CreateActor(FName("parallaxStage"), parallax));
        Check(dynamic_cast<EHWorld*>(actor.get()) == nullptr, "Background stage must not own world rules");
        Check(dynamic_cast<EHParallaxStage*>(actor.get()) != nullptr, "Stage factory failed");
        std::unique_ptr<EHActor> plain(EHActorFactory::CreateActor(FName("world"), WorldData()));
        Check(dynamic_cast<EHWorld*>(plain.get()) != nullptr, "Plain world factory failed");
    }
    void TestLimits() {
        auto world = WorldData().get<EHWorld>();
        FFighter right(7, 100, 3);
        right.physics->SetVelocity(FVector(100, 2));
        EHPhysicsSystem::Step({&right.actor}, 1, &world);
        Near(right.actor.GetPosition().x, 7.5f);
        Near(right.actor.GetPosition().y, 5);
        Near(right.physics->GetVelocity().x, 100); // Preserve movement intent at the wall.
        right.physics->SetVelocity(FVector(-2, 0));
        EHPhysicsSystem::Step({&right.actor}, 0.5f, &world);
        Near(right.actor.GetPosition().x, 6.5f);
        FFighter left(-7, -100);
        EHPhysicsSystem::Step({&left.actor}, 1, &world);
        Near(left.actor.GetPosition().x, -7.5f);
        FFighter unrestricted(7, 100);
        EHPhysicsSystem::Step({&unrestricted.actor}, 1); // Optional world preserves earlier behavior.
        Near(unrestricted.actor.GetPosition().x, 107);
        EHActor projectile;
        projectile.InitializeActor(BodyComponents(false));
        auto* physics = dynamic_cast<EHPhysicsComponent*>(projectile.GetActorComponent(FName("physics")));
        projectile.SetPosition(FVector(7, 0));
        physics->SetVelocity(FVector(100, 0));
        EHPhysicsSystem::Step({&projectile}, 1, &world);
        Near(projectile.GetPosition().x, 107);
        EHCharacter noPhysics;
        noPhysics.SetPosition(FVector(20, 4));
        EHPhysicsSystem::Step({&noPhysics}, 1, &world);
        Near(noPhysics.GetPosition().x, 7.5f);
        Near(noPhysics.GetPosition().y, 4);
    }
    void TestCorners() {
        auto world = WorldData().get<EHWorld>();
        for (bool reverse : {false, true}) {
            for (bool leftCorner : {false, true}) {
                const float sign = leftCorner ? -1.f : 1.f;
                FFighter inside(sign * 5.5f, sign * 5.f), outside(sign * 7.5f, 0);
                const std::vector<EHActor*> actors = reverse
                    ? std::vector<EHActor*>{&outside.actor, &inside.actor}
                    : std::vector<EHActor*>{&inside.actor, &outside.actor};
                for (int frame = 0; frame < 10; ++frame) {
                    EHPhysicsSystem::Step(actors, 0.1f, &world);
                    Near(inside.actor.GetPosition().x, sign * 5.5f);
                    Near(outside.actor.GetPosition().x, sign * 7.5f);
                    Check(!inside.collider->GetWorldBounds()->IsOverlapping(*outside.collider->GetWorldBounds()),
                        "Corner pushing left characters overlapping");
                }
            }
        }
        FFighter left(0, 5), right(2, -4);
        EHPhysicsSystem::Step({&left.actor, &right.actor}, 1, &world);
        Near(left.actor.GetPosition().x, 1);
        Near(right.actor.GetPosition().x, 3);
        FFighter overlap(6.5f, 0), pinned(7.5f, 0);
        EHPhysicsSystem::Step({&overlap.actor, &pinned.actor}, 1, &world);
        Near(overlap.actor.GetPosition().x, 5.5f);
        Near(pinned.actor.GetPosition().x, 7.5f);
    }
    class EHFightingTestMode : public EHGameModeFighting {
    public:
        using EHGameModeFighting::InitializeWorld;
    };
    class EHTrainingTestMode : public EHGameModeTraining {
    public:
        using EHGameModeFighting::InitializeWorld;
    };
    template<typename TMode>
    void TestFightingSimulation(TMode& mode) {
        mode.InitializeWorld();
        EHWorld* world = mode.GetWorld();
        Check(world != nullptr, "Fighting mode did not load its world");
        mode.InitializeWorld();
        Check(mode.GetWorld() == world, "World initialization was duplicated");
        EHActor* background = mode.CreateActor(FName("test_stage"));
        Check(background && mode.GetWorld() == world, "Loading a stage replaced the gameplay world");
        mode.CreateActor(FName("test_world"));
        Check(mode.GetWorld() == world, "Generic actor creation replaced the explicitly selected world");
        EHActor* actor = mode.CreateActor(FName("test_character"));
        actor->SetPosition(*world->GetSpawnPoint(1));
        Near(actor->GetPosition().x, 3);
        auto* physics = dynamic_cast<EHPhysicsComponent*>(actor->GetActorComponent(FName("physics")));
        physics->SetVelocity(FVector(100, 6));
        auto* camera = dynamic_cast<EHCameraFollow*>(mode.CreateActor(FName("test_camera")));
        camera->AddTargetActor(actor);
        mode.TickGameMode(1);
        Near(actor->GetPosition().x, 7.5f);
        Near(actor->GetPosition().y, 6);
        Near(camera->GetPosition().x, 7.5f);
        Near(camera->GetPosition().y, 1); // Late ticks see this step's resolved position.
        EHGameMode& base = mode;
        base.DestroyActor(world);
        Check(mode.GetWorld() == nullptr, "Destroyed fighting world remained registered");
        physics->SetVelocity(FVector(1, 0));
        mode.TickGameMode(1);
        Near(actor->GetPosition().x, 8.5f); // No stale world pointer after destruction.
    }
    void TestGameMode() {
        EHGameInstance instance;
        {
            EHGameMode generic;
            generic.CreateActor(FName("test_world"));
            EHActor* actor = generic.CreateActor(FName("test_character"));
            actor->SetPosition(FVector(20, 6));
            auto* physics = dynamic_cast<EHPhysicsComponent*>(actor->GetActorComponent(FName("physics")));
            physics->SetVelocity(FVector(100, -10));
            auto* camera = dynamic_cast<EHCameraFollow*>(generic.CreateActor(FName("test_camera")));
            camera->AddTargetActor(actor);
            generic.TickGameMode(1);
            Near(actor->GetPosition().x, 20);
            Near(actor->GetPosition().y, 6); // Generic modes neither integrate nor constrain physics.
            Near(camera->GetPosition().x, 20);
            Near(camera->GetPosition().y, 1); // Generic actor late ticks still run.
        }
        {
            EHFightingTestMode fighting;
            TestFightingSimulation(fighting);
        }
        {
            EHTrainingTestMode training;
            TestFightingSimulation(training);
        }
    }
    void TestProductionData() {
        const auto root = std::filesystem::path(__FILE__).parent_path().parent_path().parent_path();
        for (const char* file : {"assets/level/atlantis.json", "assets/prefabs/world/world.json"}) {
            std::ifstream stream(root / file);
            const json prefab = json::parse(stream);
            std::unique_ptr<EHActor> actor(EHActorFactory::CreateActor(
                prefab.at("actorType").get<FName>(), prefab.at("data")));
            const auto* world = dynamic_cast<EHWorld*>(actor.get());
            if (prefab.at("actorType") == "world") {
                Check(world && world->GetSpawnPoints().size() >= 2, "Production world lacks player spawn points");
                Near(world->GetMinX(), -7.5f);
                Near(world->GetMaxX(), 7.5f);
            } else {
                Check(!world && dynamic_cast<EHParallaxStage*>(actor.get()), "Background stage is not separate from world");
                Check(!prefab.at("data").contains("worldSize") && !prefab.at("data").contains("spawnPoints"),
                    "Stage prefab still contains gameplay rules");
            }
        }
    }
}
int main() {
    try {
        TestConfiguration();
        TestLimits();
        TestCorners();
        TestProductionData();
        TestGameMode();
        std::cout << "World bounds and spawn checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
