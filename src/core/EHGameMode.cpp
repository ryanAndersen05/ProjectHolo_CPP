#include "EHGameMode.h"

#include <iostream>

#include "EHGameInstance.h"
#include "datatable/EHDataTableManager.h"
#include "factory/EHActorComponentFactory.h"
#include "factory/EHActorFactory.h"
#include "library/EHJsonManager.h"

EHGameMode::EHGameMode() = default;
EHGameMode::~EHGameMode() {
    for (auto* actor : allActors) {
        delete actor; // clear all actors
    }
    for (auto* controller : controllers) {
        delete controller;
    }
}

void EHGameMode::InitializeGameMode() {

}

void EHGameMode::AddController(const FName &controllerId) {
    std::cout << controllerId.GetKey() << std::endl;
}

EHController *EHGameMode::GetControllerAtIndex(int index) const {
    if (index < 0 || index >= static_cast<int>(controllers.size())) {
        std::cout << "Controller index is out of bounds" << std::endl;
        return nullptr;
    }
    return controllers[index];
}

EHActor* EHGameMode::CreateActor(const FName& actorId, EHActor* owner, const FVector& position, float rotation, const FVector& scale) {
    // build actor
    json actorJson;
    if (!EHGameInstance::LoadAssetAsJson(actorId, actorJson)) {
        std::cout << "Failed to load actor with ActorId: " << actorId.GetKey() << std::endl;
        return nullptr;
    }

    FName actorType = actorJson.at("actorType").get<FName>();
    EHActor* newActor = EHActorFactory::CreateActor(actorType);
    if (!newActor) {
        std::cout << "Failed to create new Actor: " << std::endl;
        return nullptr;
    }
    newActor->SetOwner(owner);
    newActor->SetPosition(position);
    newActor->SetRotation(rotation);
    newActor->SetScale(scale);

    json componentJson = actorJson.at("components");
    for (auto& component : componentJson) {
        FName componentType = component.at("componentType").get<FName>();
        FName componentName = component.at("componentName").get<FName>();
        json componentData = component.at("data");
        EHActorComponent* actorComponent = EHActorComponentFactory::CreateActorComponent(componentType, componentData);
        newActor->AddComponent(componentName, actorComponent);
    }
    allActors.push_back(newActor);
    if (newActor->GetIsActive()) {
        if (newActor->GetIsTickable()) tickableActors.push_back(newActor);
        if (newActor->GetIsLateTickable()) lateTickableActors.push_back(newActor);
        if (newActor->GetIsDisplayable()) displayableActors.push_back(newActor);
    }
    return newActor;
}

void EHGameMode::DestroyActor(EHActor *actor) {
    actor->SetIsActive(false);
    // Remove actor delete here when that is implemented
    std::erase(allActors, actor);
    delete actor;
}

void EHGameMode::OnActorActive(bool isActive, EHActor *actor) {

    if (!actor) {
        std::cout << "Actor should not be null" << std::endl;
        return;
    }

    if (isActive) {
        if (actor->GetIsTickable()) {
            if (std::ranges::find(tickableActors, actor) == tickableActors.end()) {
                tickableActors.push_back(actor);
            }
        }
        if (actor->GetIsLateTickable()) {
            if (std::ranges::find(lateTickableActors, actor) == lateTickableActors.end()) {
                lateTickableActors.push_back(actor);
            }
        }
        if (actor->GetIsDisplayable()) {
            if (std::ranges::find(displayableActors, actor) == displayableActors.end()) {
                displayableActors.push_back(actor);
            }
        }
    }
    else  {
        if (actor->GetIsTickable()) {
            std::erase(tickableActors, actor);
        }
        if (actor->GetIsLateTickable()) {
            std::erase(lateTickableActors, actor);
        }
        if (actor->GetIsDisplayable()) {
            std::erase(displayableActors, actor);
        }
    }
}

void EHGameMode::TickGameMode(float deltaTime) {
    TickActors(deltaTime);
    LateTickActors(deltaTime);
}

void EHGameMode::TickActors(float deltaTime) const {
    for (EHActor* actor : tickableActors) {
        actor->TickActor(deltaTime);
    }
}

void EHGameMode::LateTickActors(float deltaTime) const {
    for (EHActor* actor : lateTickableActors) {
        actor->LateTickActor(deltaTime);
    }
}

void EHGameMode::DisplayGameMode(std::vector<FSpriteDisplayData> &displayData) const {
    for (EHActor* actor : displayableActors) {
        actor->DisplayActor(displayData);
    }
}
