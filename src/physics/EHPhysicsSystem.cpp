#include "EHPhysicsSystem.h"
#include "EHBoxColliderComponent.h"
#include "EHPhyicsComponent.h"
#include "world/EHWorld.h"
#include "character/EHCharacter.h"
#include <algorithm>
#include <cmath>

namespace {
    struct FBody {
        EHActor* actor;
        FRect bounds;
        FVector start;
        FVector end;
        bool collides;
        bool worldBounded;
    };

    // Restrict the time interval to positive vertical overlap during this step.
    bool VerticalInterval(const FBody& a, const FBody& b, float& entry, float& exit) {
        const float aMin = a.bounds.GetPosition().y;
        const float bMin = b.bounds.GetPosition().y;

        const float relative = (a.end.y - a.start.y) - (b.end.y - b.start.y);
        const float low = bMin - (aMin + a.bounds.GetSize().y);
        const float high = bMin + b.bounds.GetSize().y - aMin;
        if (relative == 0.f) return low < 0.f && high > 0.f;
        const float first = low / relative;
        const float second = high / relative;
        entry = std::max(entry, std::min(first, second));
        exit = std::min(exit, std::max(first, second));
        return entry < exit;
    }

    void ResolvePair(FBody& a, FBody& b, float deltaTime) {
        FBody* left = &a;
        FBody* right = &b;
        if (a.bounds.GetCenter().x > b.bounds.GetCenter().x) std::swap(left, right);
        float gap = right->bounds.GetPosition().x
            - (left->bounds.GetPosition().x + left->bounds.GetSize().x);
        if (left->bounds.IsOverlapping(right->bounds)) {
            // Separate existing penetration equally, without changing height or intent.
            const float correction = -gap * 0.5f;
            left->start.x -= correction;
            left->end.x -= correction;
            right->start.x += correction;
            right->end.x += correction;
            left->bounds = FRect(left->bounds.GetPosition() + FVector(-correction, 0), left->bounds.GetSize());
            right->bounds = FRect(right->bounds.GetPosition() + FVector(correction, 0), right->bounds.GetSize());
            gap = 0.f;
        }
        const float leftMove = left->end.x - left->start.x;
        const float rightMove = right->end.x - right->start.x;
        const float closing = leftMove - rightMove;
        if (closing <= 0.f) {
            // Landing into another body still needs horizontal separation, even at rest.
            const FRect leftEnd(left->bounds.GetPosition() + (left->end - left->start), left->bounds.GetSize());
            const FRect rightEnd(right->bounds.GetPosition() + (right->end - right->start), right->bounds.GetSize());
            if (leftEnd.IsOverlapping(rightEnd)) {
                const float correction = (closing - gap) * 0.5f;
                left->end.x -= correction;
                right->end.x += correction;
            }
            return; // Preserve free movement apart.
        }

        float entry = std::max(0.f, gap / closing);
        float exit = 1.f;
        const float horizontalExit = (gap + left->bounds.GetSize().x + right->bounds.GetSize().x) / closing;
        if (!VerticalInterval(*left, *right, entry, exit)
            || entry >= horizontalExit || entry > exit || entry > 1.f) return;
        // When vertical overlap begins after horizontal contact, remove that penetration too.
        const float penetration = std::max(0.f, closing * entry - gap);
        const float leftContact = left->start.x + leftMove * entry - penetration * 0.5f;
        const float rightContact = right->start.x + rightMove * entry + penetration * 0.5f;
        const float leftSpeed = leftMove / deltaTime;
        const float rightSpeed = rightMove / deltaTime;
        float sharedSpeed;
        if ((leftSpeed > 0.f && rightSpeed < 0.f) || (leftSpeed < 0.f && rightSpeed > 0.f)) sharedSpeed = leftSpeed + rightSpeed;
        else sharedSpeed = std::abs(leftSpeed) >= std::abs(rightSpeed) ? leftSpeed : rightSpeed;
        const float remainingMove = sharedSpeed * deltaTime * (exit - entry);
        left->end.x = leftContact + remainingMove + leftMove * (1.f - exit);
        right->end.x = rightContact + remainingMove + rightMove * (1.f - exit);
    }

    FRect EndBounds(const FBody& body) {
        return FRect(body.bounds.GetPosition() + (body.end - body.start), body.bounds.GetSize());
    }

    void SeparateAtWorldEdge(FBody& a, FBody& b, const EHWorld& world) {
        if (!a.worldBounded && !b.worldBounded) return;
        const FRect aBounds = EndBounds(a);
        const FRect bBounds = EndBounds(b);
        if (!aBounds.IsOverlapping(bBounds)) return;
        FBody* left = &a;
        FBody* right = &b;
        FRect leftBounds = aBounds;
        FRect rightBounds = bBounds;
        if (leftBounds.GetCenter().x > rightBounds.GetCenter().x) {
            std::swap(left, right);
            std::swap(leftBounds, rightBounds);
        }
        const float penetration = leftBounds.GetPosition().x + leftBounds.GetSize().x - rightBounds.GetPosition().x;
        const float leftRoom = left->worldBounded ? std::max(0.f, left->end.x - world.GetMinX()) : penetration;
        const float rightRoom = right->worldBounded ? std::max(0.f, world.GetMaxX() - right->end.x) : penetration;
        float leftShift = std::min(penetration * 0.5f, leftRoom);
        float rightShift = std::min(penetration * 0.5f, rightRoom);
        float remaining = penetration - leftShift - rightShift;
        const float extraLeft = std::min(remaining, leftRoom - leftShift);
        leftShift += extraLeft;
        remaining -= extraLeft;
        rightShift += std::min(remaining, rightRoom - rightShift);
        left->end.x -= leftShift;
        right->end.x += rightShift;
    }

}

void EHPhysicsSystem::Step(const std::vector<EHActor*>& actors, float deltaTime, const EHWorld* world) {
    if (deltaTime <= 0.f) return;
    std::vector<FBody> bodies;
    for (EHActor* actor : actors) {
        if (!actor || !actor->GetIsActive()) continue;
        EHPhysicsComponent* physics = nullptr;
        EHBoxColliderComponent* collider = nullptr;
        for (const auto& container : actor->components) {
            if (auto* component = dynamic_cast<EHPhysicsComponent*>(container.component)) physics = component;
            if (auto* component = dynamic_cast<EHBoxColliderComponent*>(container.component)) collider = component;
        }
        const bool worldBounded = world && dynamic_cast<EHCharacter*>(actor) != nullptr;
        if (!physics) {
            if (worldBounded) actor->SetPosition(world->ClampPosition(actor->GetPosition()));
            continue;
        }
        const float step = deltaTime * actor->GetActorTimeScale();
        if (step < 0.f) continue;
        if (physics->useGravity) physics->UpdateVelocityFromGravity(step);
        const FVector start = actor->GetPosition();
        FVector end = start + physics->GetVelocity() * step;
        if (end.y <= 0.f) {
            end.y = 0.f;
            if (physics->velocity.y < 0.f) physics->velocity.y = 0.f;
        }
        const auto bounds = collider ? collider->GetWorldBounds() : std::nullopt;
        const bool collides = bounds && bounds->GetSize().x > 0.f && bounds->GetSize().y > 0.f;
        bodies.push_back({actor, bounds.value_or(FRect()), start, end, collides, worldBounded});
    }
    // Stable spatial order keeps pair processing independent of the actor tick order.
    std::stable_sort(bodies.begin(), bodies.end(), [](const FBody& a, const FBody& b) {
        return a.bounds.GetCenter().x < b.bounds.GetCenter().x;
    });
    for (std::size_t i = 0; i < bodies.size(); ++i) {
        if (!bodies[i].collides) continue;
        for (std::size_t j = i + 1; j < bodies.size(); ++j) {
            if (bodies[j].collides) ResolvePair(bodies[i], bodies[j], deltaTime);
        }
    }
    if (world) {
        for (FBody& body : bodies) {
            if (body.worldBounded) body.end = world->ClampPosition(body.end);
        }
        // A character pinned to a wall transfers the separation to the other body.
        for (std::size_t i = 0; i < bodies.size(); ++i) {
            if (!bodies[i].collides) continue;
            for (std::size_t j = i + 1; j < bodies.size(); ++j) {
                if (bodies[j].collides) SeparateAtWorldEdge(bodies[i], bodies[j], *world);
            }
        }
    }
    for (const FBody& body : bodies) body.actor->SetPosition(body.end);
}
