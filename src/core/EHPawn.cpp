#include "EHPawn.h"
#include "character/EHInputComponent.h"

EHPawn::~EHPawn() {
    AssignController(nullptr);
}

void EHPawn::AssignController(EHController *controller) {
    if (owningController == controller) return;
    EHController* oldController = owningController;
    owningController = controller;
    EHInputComponent* inputComponent = dynamic_cast<EHInputComponent*>(GetActorComponent(FName("input")));
    if (!inputComponent) return;

    if (controller) {
        inputComponent->InitializeController(controller);

    }
    else {
        inputComponent->UninitializeController(oldController);
    }
}
