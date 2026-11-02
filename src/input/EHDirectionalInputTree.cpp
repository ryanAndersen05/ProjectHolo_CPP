#include "EHDirectionalInputTree.h"

void EHDirectionalInputTree::AddCommand(const FDirectionalCommand& command) {
    if (command.directions.empty()) return;
    int index = 0;
    for (auto it = command.directions.rbegin(); it != command.directions.rend(); ++it) {
        const auto direction = static_cast<std::size_t>(*it);
        int next = nodes[index].branches[direction];
        if (next < 0) {
            next = static_cast<int>(nodes.size());
            nodes[index].branches[direction] = next;
            nodes.emplace_back();
        }
        index = next;
    }
    nodes[index].motion = command.motion;
}

EDirectionalMotion EHDirectionalInputTree::Match(std::span<const EDirectionalInput> directions) const {
    int index = 0;
    EDirectionalMotion result = EDirectionalMotion::None;
    for (const auto direction : directions) {
        index = nodes[index].branches[static_cast<std::size_t>(direction)];
        if (index < 0) break;
        if (nodes[index].motion != EDirectionalMotion::None) result = nodes[index].motion;
    }
    return result;
}

EDirectionalInput EHDirectionalInputTree::ToDirection(int horizontal, int vertical, bool facingLeft) {
    return static_cast<EDirectionalInput>(4 + vertical * 3 + horizontal * (facingLeft ? -1 : 1));
}

const EHDirectionalInputTree& EHDirectionalInputTree::GetDefault() {
    static const EHDirectionalInputTree tree = [] {
        EHDirectionalInputTree result;
        using enum EDirectionalInput;
        result.AddCommand({EDirectionalMotion::QuarterCircleForward, {Down, DownForward, Forward}});
        result.AddCommand({EDirectionalMotion::QuarterCircleForward, {Down, Forward}});
        result.AddCommand({EDirectionalMotion::QuarterCircleBack, {Down, DownBack, Back}});
        result.AddCommand({EDirectionalMotion::QuarterCircleBack, {Down, Back}});
        result.AddCommand({EDirectionalMotion::DoubleForward, {Neutral, Forward, Neutral, Forward}});
        result.AddCommand({EDirectionalMotion::DoubleForward, {Neutral, UpForward, Neutral, Forward}});
        result.AddCommand({EDirectionalMotion::DoubleForward, {Neutral, UpForward, Forward, Neutral, Forward}});
        result.AddCommand({EDirectionalMotion::DoubleBack, {Neutral, Back, Neutral, Back}});
        result.AddCommand({EDirectionalMotion::DoubleBack, {Neutral, UpBack, Neutral, Back}});
        result.AddCommand({EDirectionalMotion::DoubleBack, {Neutral, UpBack, Back, Neutral, Back}});
        result.AddCommand({EDirectionalMotion::DoubleDown, {Neutral, Down, Neutral, Down}});
        result.AddCommand({EDirectionalMotion::DoubleQuarterCircleForward,
            {Down, DownForward, Forward, Neutral, Down, DownForward, Forward}});
        result.AddCommand({EDirectionalMotion::DoubleQuarterCircleForward,
            {Down, DownForward, Forward, Down, DownForward, Forward}});
        result.AddCommand({EDirectionalMotion::DoubleQuarterCircleForward,
            {Down, DownForward, Forward, DownForward, Down, DownForward, Forward}});
        return result;
    }();
    return tree;
}
