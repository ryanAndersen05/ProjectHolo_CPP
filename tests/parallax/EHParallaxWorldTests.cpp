#include "world/EHParallaxWorld.h"
#include "camera/EHCamera.h"
#include "factory/EHActorFactory.h"
#include "sprite/EHSpriteComponent.h"
#include <cmath>
#include <iostream>
#include <memory>
#include <fstream>
#include <filesystem>
#include <stdexcept>

namespace {
    void Check(bool condition, const char* message) {
        if (!condition) throw std::runtime_error(message);
    }
    void Near(float actual, float expected) {
        Check(std::abs(actual - expected) < 0.0001f, "Unexpected parallax position");
    }
    json Sprite(const char* name, int order) {
        return {{"componentType", "sprite"}, {"componentName", name}, {"data", {
            {"defaultSprite", ""}, {"spriteOffset", FVector(1, 2)}, {"drawOrder", order}}}};
    }
    json Definition() {
        return {{"backgroundLayers", json::array({
            {{"componentName", "near"}, {"z", 0}, {"offset", FVector(2, 3)}},
            {{"componentName", "far"}, {"z", 5}, {"offset", FVector(-2, 1)}}})}};
    }
    void TestLayers() {
        auto world = Definition().get<EHParallaxWorld>();
        world.InitializeActor(json::array({Sprite("near", -100), Sprite("far", -200)}));
        world.SetPosition(FVector(10, 20));
        Check(world.GetIsDisplayable(), "World not registered for drawing");
        EHActor cameraActor;
        EHCamera camera;
        json{{"offset", FVector(2, 3)}, {"cameraSize", 20}}.get_to(camera);
        camera.InitializeComponent(&cameraActor);
        cameraActor.SetPosition(FVector(4, 9));
        FRenderContext context{nullptr, &camera};
        FRenderQueue queue;
        // Call via the base actor, as the game mode does.
        const EHActor& actor = world;
        actor.DisplayActor(queue, context);
        Check(queue.sprites.size() == 2, "Layers were missing or submitted twice");
        Check(queue.debugRectangles.empty(), "World submitted unexpected geometry");
        Near(queue.sprites[0].position.x, 13);
        Near(queue.sprites[0].position.y, 25);
        Near(queue.sprites[1].position.x, 14);
        Near(queue.sprites[1].position.y, 33);
        Check(queue.sprites[0].drawOrder == -100 && queue.sprites[1].drawOrder == -200,
            "Authored sprite ordering was lost");
        // Screen-space movement is authored position minus camera position.
        const float farScreenX = queue.sprites[1].position.x - camera.GetViewPosition().x;
        cameraActor.SetPosition(FVector(10, 9));
        queue.sprites.clear();
        actor.DisplayActor(queue, context);
        Near(queue.sprites[1].position.x - camera.GetViewPosition().x, farScreenX - 1);
        Near(queue.sprites[0].position.x, 13); // Z=0 has no world-space adjustment.
        const float farPosition = queue.sprites[1].position.x;
        for (int frame = 0; frame < 100; ++frame) {
            queue.sprites.clear();
            actor.DisplayActor(queue, context);
            Near(queue.sprites[1].position.x, farPosition);
        }
        queue.sprites.clear();
        actor.DisplayActor(queue, {}); // No camera: authored positions are retained.
        Near(queue.sprites[1].position.x, 9);
        Near(queue.sprites[1].position.y, 23);
        auto* far = dynamic_cast<EHSpriteComponent*>(world.GetActorComponent(FName("far")));
        Check(far != nullptr, "Sprite component missing");
        Near(far->GetSpriteDrawData().position.x, 11); // Underlying transform never mutates.
    }
    void TestProductionPrefab() {
        const auto root = std::filesystem::path(__FILE__).parent_path().parent_path().parent_path();
        std::ifstream tableFile(root / "assets/datatables/assetPathDataTable.json");
        const json table = json::parse(tableFile);
        for (const char* id : {"atlantis", "atlantis_background_atlas", "atlantis_background_texture"}) {
            int matches = 0;
            for (const auto& row : table.at("rows")) {
                if (row.at("rowId") == id) {
                    ++matches;
                    Check(std::filesystem::is_regular_file(root / row.at("assetPath").get<std::string>()),
                        "Stage asset path is missing");
                }
            }
            Check(matches == 1, "Stage asset registration is missing or duplicated");
        }
        std::ifstream stageFile(root / "assets/level/atlantis.json");
        json stage = json::parse(stageFile);
        // Keep the real prefab's geometry and ordering; avoid GPU resource creation in checks.
        stage["data"].erase("spriteAsset");
        for (auto& component : stage["components"]) component["data"]["defaultSprite"] = "";
        std::unique_ptr<EHActor> actor(EHActorFactory::CreateActor(
            stage.at("actorType").get<FName>(), stage.at("data")));
        actor->InitializeActor(stage.at("components"));
        FRenderQueue queue;
        actor->DisplayActor(queue, {});
        Check(queue.sprites.size() == 3, "Atlantis did not produce all three background layers");
        Check(queue.sprites[0].drawOrder < queue.sprites[1].drawOrder
            && queue.sprites[1].drawOrder < queue.sprites[2].drawOrder
            && queue.sprites[2].drawOrder < 0, "Atlantis background ordering is incorrect");
    }
    void TestValidationAndFactory() {
        auto world = Definition().get<EHParallaxWorld>();
        for (int invalidCase = 0; invalidCase < 4; ++invalidCase) {
            json invalid = Definition();
            if (invalidCase == 0) invalid["backgroundLayers"][0]["z"] = -1;
            if (invalidCase == 1) invalid["backgroundLayers"][0]["componentName"] = "";
            if (invalidCase == 2) invalid["backgroundLayers"][1]["componentName"] = "near";
            if (invalidCase == 3) invalid["backgroundLayers"] = json::object();
            bool rejected = false;
            try { invalid.get_to(world); } catch (const std::exception&) { rejected = true; }
            Check(rejected && world.GetBackgroundLayers().size() == 2, "Invalid layers changed configuration");
        }
        bool rejected = false;
        try { world.InitializeActor(json::array()); } catch (const std::exception&) { rejected = true; }
        Check(rejected, "Missing sprite reference was accepted");
        std::unique_ptr<EHActor> created(EHActorFactory::CreateActor(FName("parallaxWorld"), Definition()));
        Check(dynamic_cast<EHParallaxWorld*>(created.get()) != nullptr, "Factory did not create parallax world");
        created->InitializeActor(json::array({Sprite("near", -100), Sprite("far", -200)}));
        FRenderQueue queue;
        created->DisplayActor(queue, {});
        Check(queue.sprites.size() == 2, "Factory-created world did not render layers");
    }
}
int main() {
    try {
        TestLayers();
        TestValidationAndFactory();
        TestProductionPrefab();
        std::cout << "Parallax world checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
