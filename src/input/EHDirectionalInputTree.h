#pragma once
#include <array>
#include <cstdint>
#include <span>
#include <vector>

enum class EDirectionalInput : std::uint8_t {
    DownBack,
    Down,
    DownForward,
    Back,
    Neutral,
    Forward,
    UpBack,
    Up,
    UpForward
};

enum class EDirectionalMotion : std::uint8_t {
    None,
    DoubleForward,
    DoubleBack,
    DoubleDown,
    QuarterCircleForward,
    QuarterCircleBack,
    DoubleQuarterCircleForward
};

struct FDirectionalCommand {
    EDirectionalMotion motion;
    std::vector<EDirectionalInput> directions; // Oldest to newest.
};

class EHDirectionalInputTree {
private:
    struct FNode {
        std::array<int, 9> branches;
        EDirectionalMotion motion = EDirectionalMotion::None;
        FNode() { branches.fill(-1); }
    };
    std::vector<FNode> nodes = std::vector<FNode>(1);
public:
    void AddCommand(const FDirectionalCommand& command);
    // Most recent direction first. Returns the deepest completed match.
    [[nodiscard]] EDirectionalMotion Match(std::span<const EDirectionalInput> directions) const;
    [[nodiscard]] static EDirectionalInput ToDirection(int horizontal, int vertical, bool facingLeft);
    [[nodiscard]] static const EHDirectionalInputTree& GetDefault();
};
