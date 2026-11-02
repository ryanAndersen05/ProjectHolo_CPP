#include "physics/EHBoxColliderComponent.h"
#include "physics/EHPhyicsComponent.h"
#include "physics/EHPhysicsSystem.h"
#include <cmath>
#include <iostream>
#include <limits>
#include <stdexcept>

namespace {
    void Check(bool condition, const char* message) {
        if (!condition) throw std::runtime_error(message);
    }
    void Near(float actual, float expected) {
        if (std::abs(actual - expected) >= 0.0001f || !std::isfinite(actual))
            throw std::runtime_error("Expected " + std::to_string(expected) + ", got " + std::to_string(actual));
    }
    struct Fighter {
        EHActor actor;
        EHPhysicsComponent* physics;
        EHBoxColliderComponent* collider;
        Fighter(float x, float vx, float y = 0.f) {
            physics = new EHPhysicsComponent(json{
                {"useGravity", false}, {"gravityScale", 1.f},
                {"useTerminalVelocity", false}, {"terminalVelocity", 10.f}}.get<EHPhysicsComponent>());
            collider = new EHBoxColliderComponent();
            actor.AddComponent(FName("arbitrary_physics_name"), physics);
            actor.AddComponent(FName("arbitrary_collider_name"), collider);
            collider->SetBounds(FVector(2, 4), FVector::Zero);
            actor.SetPosition(FVector(x, y));
            physics->SetVelocity(FVector(vx, 0));
        }
    };
    void Push(float leftSpeed, float rightSpeed, float expected, bool reverse) {
        Fighter left(0, leftSpeed), right(2, rightSpeed);
        const std::vector<EHActor*> actors = reverse
            ? std::vector<EHActor*>{&right.actor, &left.actor}
            : std::vector<EHActor*>{&left.actor, &right.actor};
        for (int frame = 1; frame <= 10; ++frame) {
            EHPhysicsSystem::Step(actors, 0.1f);
            Near(left.actor.GetPosition().x, expected * 0.1f * frame);
            Near(right.actor.GetPosition().x, 2.f + expected * 0.1f * frame);
            Near(left.actor.GetPosition().y, 0.f);
            Near(right.actor.GetPosition().y, 0.f);
            Near(left.physics->GetVelocity().x, leftSpeed);
            Near(right.physics->GetVelocity().x, rightSpeed);
        }
    }
    void TestBounds() {
        EHBoxColliderComponent unattached;
        Check(!unattached.GetWorldBounds(), "Unattached bounds existed");
        Fighter fighter(10, 0);
        Near(fighter.collider->GetWorldBounds()->GetPosition().x, 9);
        Near(fighter.collider->GetWorldBounds()->GetPosition().y, 0);
        fighter.collider->SetBounds(FVector(2, 4), FVector(0.5f, 1));
        fighter.actor.SetScale(FVector(-2, -3));
        fighter.actor.SetRotation(75);
        const auto bounds = fighter.collider->GetWorldBounds();
        Near(bounds->GetPosition().x, 7);
        Near(bounds->GetPosition().y, 3);
        Near(bounds->GetSize().x, 4);
        Near(bounds->GetSize().y, 12);
        Check(!fighter.collider->SetBounds(FVector(-1, 2), FVector::Zero), "Negative size accepted");
        Check(!fighter.collider->SetBounds(FVector(1, 2), FVector(0, -1)), "Collider extended below feet");
        Check(!fighter.collider->SetBounds(FVector(1, 2), FVector(std::numeric_limits<float>::infinity(), 0)), "Infinity accepted");
        Near(fighter.collider->GetOffset().x, 0.5f);
        const auto loaded = json{{"size", FVector(3, 5)}}.get<EHBoxColliderComponent>();
        Near(loaded.GetSize().x, 3);
        Near(loaded.GetOffset().y, 0);
    }
    void TestContacts() {
        {
            Fighter left(0, -5), right(2, 4);
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 1);
            Near(left.actor.GetPosition().x, -5);
            Near(right.actor.GetPosition().x, 6);
        }
        {
            Fighter left(0, 100), right(10, -100);
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 1);
            Near(left.actor.GetPosition().x, 4);
            Near(right.actor.GetPosition().x, 6);
        }
        {
            Fighter left(0, 5), right(4, -4);
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 1);
            Near(left.actor.GetPosition().x, 17.f / 9.f);
            Near(right.actor.GetPosition().x, 35.f / 9.f);
        }
        {
            Fighter left(0, 0), right(1, 0);
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 0.1f);
            Near(left.actor.GetPosition().x, -0.5f);
            Near(right.actor.GetPosition().x, 1.5f);
        }
        {
            Fighter left(0, 0), right(0, 0);
            right.collider->SetBounds(FVector(1, 2), FVector::Zero);
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 0.1f);
            Check(!left.collider->GetWorldBounds()->IsOverlapping(*right.collider->GetWorldBounds()), "Contained collider not separated");
        }
    }
    void TestAirAndIntegration() {
        {
            Fighter left(0, -1), right(1, 1);
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 0.1f);
            Near(left.actor.GetPosition().x, -0.6f);
            Near(right.actor.GetPosition().x, 1.6f);
        }
        {
            Fighter left(0, 5), right(2, -4);
            left.physics->SetVelocity(FVector(5, 8));
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 1);
            // Contact lasts half the step, then the jumper moves freely.
            Near(left.actor.GetPosition().x, 3);
            Near(right.actor.GetPosition().x, 0.5f);
            Near(left.actor.GetPosition().y, 8);
            Near(left.physics->GetVelocity().y, 8);
        }
        {
            Fighter falling(0, 0, 10);
            falling.physics->SetGravityScale(1);
            // Reload only physics settings; the owning actor remains attached.
            json{{"useGravity", true}, {"gravityScale", 1},
                {"useTerminalVelocity", true}, {"terminalVelocity", 3}}.get_to(*falling.physics);
            EHPhysicsSystem::Step({&falling.actor}, 1);
            Near(falling.actor.GetPosition().y, 7);
            Near(falling.physics->GetVelocity().y, -3);
        }
        {
            EHActor actor;
            auto* physics = new EHPhysicsComponent();
            physics->SetVelocity(FVector(2, 0));
            actor.AddComponent(FName("physics"), physics);
            EHPhysicsSystem::Step({&actor}, 0.5f);
            Near(actor.GetPosition().x, 1);
        }
        {
            Fighter left(0, 20, 4), right(5, 0);
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 1);
            Near(left.actor.GetPosition().x, 20);
            Near(left.actor.GetPosition().y, 4);
        }
        {
            Fighter left(0, 0, 5), right(0, 0);
            left.physics->SetVelocity(FVector(0, -2));
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 1);
            Near(left.actor.GetPosition().y, 3);
            Near(left.physics->GetVelocity().y, -2);
            Check(!left.collider->GetWorldBounds()->IsOverlapping(*right.collider->GetWorldBounds()), "Landing overlap not separated sideways");
        }
        {
            Fighter left(0, 20, 10), right(5, 0);
            left.physics->SetVelocity(FVector(20, -10));
            EHPhysicsSystem::Step({&left.actor, &right.actor}, 1);
            Near(left.actor.GetPosition().x, 20);
        }
        {
            Fighter moving(0, 5), inactive(2, 0);
            inactive.actor.SetIsActive(false);
            moving.actor.SetTimeScale(0.5f);
            moving.actor.TickActor(1);
            Near(moving.actor.GetPosition().x, 0);
            EHPhysicsSystem::Step({&moving.actor, &inactive.actor}, 1);
            Near(moving.actor.GetPosition().x, 2.5f);
            Near(inactive.actor.GetPosition().x, 2);
            EHPhysicsSystem::Step({&moving.actor}, 0);
            Near(moving.actor.GetPosition().x, 2.5f);
        }
        {
            Fighter falling(0, 0, 1);
            falling.physics->SetVelocity(FVector(0, -5));
            EHPhysicsSystem::Step({&falling.actor}, 1);
            Near(falling.actor.GetPosition().y, 0);
            Near(falling.physics->GetVelocity().y, 0);
        }
    }
}
int main() {
    try {
        TestBounds();
        for (bool reverse : {false, true}) {
            Push(5, -4, 1, reverse);
            Push(4, -5, -1, reverse);
            Push(5, -5, 0, reverse);
            Push(5, 4, 5, reverse);
            Push(-4, -5, -5, reverse);
            Push(5, 0, 5, reverse);
            Push(0, -5, -5, reverse);
        }
        TestContacts();
        TestAirAndIntegration();
        std::cout << "Character physics checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
