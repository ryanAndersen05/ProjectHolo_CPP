#include "character/EHInputComponent.h"
#include "core/EHGameInstance.h"
#include <iostream>
#include <stdexcept>

namespace {
    void Check(bool condition, const char* message) {
        if (!condition) throw std::runtime_error(message);
    }
    struct FDetectedMotion { EDirectionalMotion motion; int frame; };
    struct FInputHarness {
        EHController controller;
        EHActor actor;
        EHInputComponent* input;
        EHAnimatorComponent* animator;
        int frame = 0;
        std::vector<FDetectedMotion> detected;
        FInputHarness(bool facingLeft = false) {
            actor.SetScale(FVector(facingLeft ? -1.f : 1.f, 1));
            animator = new EHAnimatorComponent(json{{"stateMachineAsset", "input_test_states"}}.get<EHAnimatorComponent>());
            actor.AddComponent(FName("animator"), animator);
            input = new EHInputComponent();
            actor.AddComponent(FName("input"), input);
            input->InitializeController(&controller);
            input->OnDirectionalInputEvent.AddListener([this](EDirectionalMotion motion, int inputFrame) {
                detected.push_back({motion, inputFrame});
            });
            Sample(EButton::None);
        }
        ~FInputHarness() { input->UninitializeController(&controller); }
        void Sample(EButton buttons) {
            controller.AssignButton(buttons, frame);
            controller.TickController(frame++);
        }
        void Direction(EDirectionalInput direction, bool facingLeft, int heldFrames = 1) {
            const int value = static_cast<int>(direction);
            int horizontal = value % 3 - 1;
            const int vertical = value / 3 - 1;
            if (facingLeft) horizontal = -horizontal;
            EButton buttons = EButton::None;
            if (horizontal < 0) buttons |= EButton::Left;
            if (horizontal > 0) buttons |= EButton::Right;
            if (vertical < 0) buttons |= EButton::Down;
            if (vertical > 0) buttons |= EButton::Up;
            for (int i = 0; i < heldFrames; ++i) Sample(buttons);
        }
    };
    void TestVariants() {
        using enum EDirectionalInput;
        const std::vector<FDirectionalCommand> commands = {
            {EDirectionalMotion::QuarterCircleForward, {Down, DownForward, Forward}},
            {EDirectionalMotion::QuarterCircleForward, {Down, Forward}},
            {EDirectionalMotion::QuarterCircleBack, {Down, DownBack, Back}},
            {EDirectionalMotion::QuarterCircleBack, {Down, Back}},
            {EDirectionalMotion::DoubleForward, {Neutral, Forward, Neutral, Forward}},
            {EDirectionalMotion::DoubleForward, {Neutral, UpForward, Neutral, Forward}},
            {EDirectionalMotion::DoubleForward, {Neutral, UpForward, Forward, Neutral, Forward}},
            {EDirectionalMotion::DoubleBack, {Neutral, Back, Neutral, Back}},
            {EDirectionalMotion::DoubleBack, {Neutral, UpBack, Neutral, Back}},
            {EDirectionalMotion::DoubleBack, {Neutral, UpBack, Back, Neutral, Back}},
            {EDirectionalMotion::DoubleDown, {Neutral, Down, Neutral, Down}},
            {EDirectionalMotion::DoubleQuarterCircleForward, {Down, DownForward, Forward, Neutral, Down, DownForward, Forward}},
            {EDirectionalMotion::DoubleQuarterCircleForward, {Down, DownForward, Forward, Down, DownForward, Forward}},
            {EDirectionalMotion::DoubleQuarterCircleForward, {Down, DownForward, Forward, DownForward, Down, DownForward, Forward}}
        };
        for (bool facingLeft : {false, true}) {
            for (const auto& command : commands) {
                FInputHarness harness(facingLeft);
                for (const auto direction : command.directions) harness.Direction(direction, facingLeft, 2);
                Check(!harness.detected.empty(), "Motion variant was not detected");
                Check(harness.detected.back().motion == command.motion, "Wrong motion or longest-match priority");
                Check(harness.detected.back().frame == harness.frame - 2, "Motion was not emitted on the completing frame");
            }
        }
    }
    void TestWindowAndChanges() {
        {
            FInputHarness harness;
            harness.Sample(EButton::Down);
            harness.Sample(EButton::Right); // Press Right and release Down share a frame.
            Check(harness.detected.size() == 1, "Press/release callbacks emitted a duplicate motion");
            Check(harness.animator->GetBool(FName("qcf")), "Motion did not buffer its animator trigger");
            for (int i = 0; i < 30; ++i) harness.Sample(EButton::Right);
            harness.Sample(EButton::Right | EButton::Light);
            Check(harness.detected.size() == 1, "Held direction or attack repeated a motion");
            Check(harness.animator->GetBool(FName("light")), "Attack input stopped working");
        }
        for (int delay : {18, 19}) {
            FInputHarness harness;
            harness.Sample(EButton::Down);
            for (int i = 0; i < delay; ++i) harness.Sample(EButton::Down | EButton::Right);
            harness.Sample(EButton::Right);
            Check(harness.detected.empty() == (delay == 19), "Incorrect twenty-frame motion boundary");
        }
        {
            FInputHarness harness;
            harness.Sample(EButton::Down);
            harness.Sample(EButton::Up); // Unrelated direction interrupts the sequence.
            harness.Sample(EButton::Right);
            Check(harness.detected.empty(), "Skipped an unrelated direction");
        }
        {
            FInputHarness harness;
            harness.Sample(EButton::Left | EButton::Right); // Still Neutral, not another tap.
            harness.Sample(EButton::Right);
            Check(harness.detected.empty(), "Opposite-input masks created a false double tap");
        }
        {
            FInputHarness harness;
            harness.Sample(EButton::Down);
            harness.Sample(EButton::Down | EButton::Left);
            harness.actor.SetScale(FVector(-1, 1));
            harness.Sample(EButton::Left);
            Check(harness.detected.size() == 1 && harness.detected.back().motion == EDirectionalMotion::QuarterCircleForward,
                "History was not interpreted using current facing");
        }
    }
    void TestBufferAndBinding() {
        FInputHarness harness;
        harness.Sample(EButton::Down);
        harness.Sample(EButton::Right);
        for (int i = 0; i < 7; ++i) harness.input->Tick(0);
        Check(harness.animator->GetBool(FName("qcf")), "Motion buffer expired early");
        harness.Sample(EButton::Down);
        harness.Sample(EButton::Right);
        harness.input->Tick(0);
        Check(harness.animator->GetBool(FName("qcf")), "Repeated motion did not refresh its buffer");
        for (int i = 0; i < 7; ++i) harness.input->Tick(0);
        Check(!harness.animator->GetBool(FName("qcf")), "Motion buffer did not expire");
        harness.Sample(EButton::Light);
        harness.input->InitializeController(&harness.controller); // Idempotent subscription.
        harness.Sample(EButton::Down);
        harness.Sample(EButton::Right);
        Check(harness.detected.size() == 3, "Rebinding duplicated the subscription");
        harness.input->UninitializeController(&harness.controller);
        Check(!harness.animator->GetBool(FName("qcf")) && !harness.animator->GetBool(FName("light")), "Unbinding left stale triggers");
        EHController other;
        other.AssignButton(EButton::Down, 10);
        other.AssignButton(EButton::Down | EButton::Right, 11);
        harness.input->InitializeController(&other);
        other.AssignButton(EButton::Right, 12);
        other.TickController(12);
        Check(harness.detected.size() == 3, "New controller reused pre-binding motion history");
        harness.input->UninitializeController(&other);
    }
}
int main() {
    try {
        EHGameInstance instance;
        TestVariants();
        TestWindowAndChanges();
        TestBufferAndBinding();
        std::cout << "Directional input checks passed\n";
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
