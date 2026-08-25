#include "EHGameInstance.h"
#include <iostream>
#include "factory/EHGameModeFactory.h"

EHGameInstance* EHGameInstance::instance = nullptr;

EHGameInstance::EHGameInstance() : gameMode(nullptr), gameHUD(nullptr) {
    if (instance != nullptr) {
        std::cout << "EHGameInstance already exists. You should never try to make two." << std::endl;
        return;
    }
    EHGameInstance::instance = this;

    if (!EHJsonManager::Deserialize<EHDataTable<EHAssetPathTableRow>>("assets/datatables/assetPathDataTable.json", assetPathTable)) {
        std::cerr << "Failed to deserialize EHDataTable<EHAssetPathTableRow>" << std::endl;
        return;
    }
    spriteManager = new EHSpriteManager();
    dataTableManager = new EHDataTableManager();
}

EHGameInstance::~EHGameInstance() {
    delete spriteManager;
    delete dataTableManager;
}

void EHGameInstance::InitializeGame(const FWorldSettings &worldSettings) {
    delete gameMode;
    delete gameHUD;

    json gameModeJson;
    if (!LoadAssetAsJson_Instance(worldSettings.gameMode, gameModeJson)) {
        std::cout << "Failed to Deserialize GameMode" << std::endl;
        return;
    }
    FName gameModeType = gameModeJson.at("gameModeType").get<FName>();
    gameMode = EHGameModeFactory::CreateGameMode(gameModeType, gameModeJson.at("data"));
    if (gameMode) gameMode->InitializeGameMode();
    // if (gameHUD)
}

void EHGameInstance::TickGame(float deltaTime) const {
    if (gameMode) gameMode->TickGameMode(deltaTime);
    if (gameHUD != nullptr) gameHUD->TickGameHUD();
}

void EHGameInstance::DisplayGame(sf::RenderWindow &window) const {
    window.clear(sf::Color::Black);

    std::vector<FSpriteDisplayData> displayData;
    if (gameMode) gameMode->DisplayGameMode(displayData);
    for (const FSpriteDisplayData& data : displayData) {
        const FSpriteDrawData& drawData = data.drawData;
        const FSpriteData& spriteData = drawData.spriteData;
        FVector position = data.position * 32.f;
        sf::Sprite sprite(*drawData.texture,
            sf::IntRect({spriteData.point.x, spriteData.point.y},{spriteData.size.x, spriteData.size.y}));
        sprite.setPosition({position.x, -position.y});
        window.draw(sprite);
    }
    window.display();
}


