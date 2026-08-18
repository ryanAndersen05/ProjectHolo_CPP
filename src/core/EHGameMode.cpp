#include "EHGameMode.h"

#include <iostream>

#include "EHGameInstance.h"
#include "datatable/EHDataTableManager.h"
#include "factory/EHActorComponentFactory.h"
#include "factory/EHActorFactory.h"
#include "library/EHJsonManager.h"

EHGameMode::EHGameMode() = default;
EHGameMode::~EHGameMode() = default;

void EHGameMode::AddController(const FName &controllerId) {
    std::cout << controllerId.GetKey() << std::endl;
}

EHActor* CreateActor(const FName& actorId, EHActor* owner, const FVector& position, float rotation, const FVector& scale) {
    // build actor
    EHDataTableManager* dataTableManager = EHGameInstance::GetInstance()->GetDataTableManager();
    if (dataTableManager == nullptr) {
        std::cout << "Failed to find dataTableManager in Game Instance"  << std::endl;
        return nullptr;
    }
    EHActorTableRow actorRow;
    if (!dataTableManager->GetActorData(actorId, actorRow)) {
        std::cout << "Failed to find row: " << actorId.GetKey() << std::endl;
        return nullptr;
    }
    json actorJson;
    if (!EHJsonManager::DeserializeAsJson(actorRow.GetActorPath(), actorJson)) {
        std::cout << "No Item Found At Path: " << actorRow.GetActorPath() << std::endl;
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
        json componentData = component.at("data");
        EHActorComponent* actorComponent = EHActorComponentFactory::CreateActorComponent(componentType, componentData);
        newActor->AddComponent(componentType, actorComponent);
    }

    return newActor;
}

void EHGameMode::TickGameMode() {
    // nothing here for now
}
