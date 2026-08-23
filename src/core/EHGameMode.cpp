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
    EHDataTableManager* dataTableManager = EHGameInstance::GetInstance()->GetDataTableManager();
    if (dataTableManager == nullptr) {
        std::cout << "Failed to find dataTableManager in Game Instance"  << std::endl;
        return nullptr;
    }
    EHAssetPathTableRow actorRow;
    if (!dataTableManager->GetAssetPathData(actorId, actorRow)) {
        std::cout << "Failed to find row: " << actorId.GetKey() << std::endl;
        return nullptr;
    }
    json actorJson;
    if (!EHJsonManager::DeserializeAsJson(actorRow.GetAssetPath(), actorJson)) {
        std::cout << "No Item Found At Path: " << actorRow.GetAssetPath() << std::endl;
        return nullptr;
    }

    FName actorType = actorJson.at("actorType").get<FName>();
    EHActor* newActor = EHActorFactory::CreateActor(actorType);
    if (newActor == nullptr) {
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
        EHActorComponent* actorComponent = EHActorComponentFactory::CreateActorComponent(componentName, componentData);
        newActor->AddComponent(componentType, actorComponent);
    }
    allActors.push_back(newActor);
    if (newActor->GetIsActive()) {
        if (newActor->GetIsTickable()) tickableActors.push_back(newActor);
        if (newActor->GetIsLateTickable()) lateTickableActors.push_back(newActor);
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

    if (actor == nullptr) {
        std::cout << "Actor should not be null" << std::endl;
        return;
    }
    
    if (isActive) {
        if (actor->GetIsLateTickable()) {
            if (std::ranges::find(tickableActors, actor) == tickableActors.end()) {
                tickableActors.push_back(actor);
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
    }
}

void EHGameMode::TickGameMode() {
    // nothing here for now
}
