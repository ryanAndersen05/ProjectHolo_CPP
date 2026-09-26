#include "library/EHLibrary.h"
#include <cmath>

const FVector FVector::Zero = FVector(0.f, 0.f);
const FVector FVector::One = FVector(1.f, 1.f);
const FVector FVector::Right = FVector(1.f, 0.f);
const FVector FVector::Left = FVector(-1.f, 0.f);
const FVector FVector::Up = FVector(0.f, 1.f);
const FVector FVector::Down = FVector(0.f, -1.f);

const FVectorInt FVectorInt::Zero = FVectorInt(0, 0);
const FVectorInt FVectorInt::One = FVectorInt(1, 1);

float FVector::GetMagnitude() const
{
    return sqrtf(x * x + y * y);
}

float FVector::GetMagnitudeSquared() const
{
    return x * x + y * y;
}

FVector FVector::GetNormal() const
{
    const float mag = GetMagnitude();
    if (mag == 0.f) return FVector::Zero;
    return FVector(x / mag, y / mag);
}

void FVector::normalize()
{
    float mag = GetMagnitude();
    if (mag == 0.f)
    {
        x = 0;
        y = 0;
        return;
    }
    x /= mag;
    y /= mag;
}

float FVector::Dot(const FVector &vec1, const FVector &vec2) {
    return vec1.x * vec2.x + vec1.y * vec2.y;
}

std::string FVectorInt::to_string() const {
    return "x: " + std::to_string(x) + "y: " + std::to_string(y);
}

FRect::FRect(const FVector& position, const FVector& size) : position(position), size(size) {
    maxBounds = position + size;
    minBounds = position;
}

bool FRect::IsOverlapping(const FRect& rect) const
{
    FVector min = minBounds;
    FVector max = maxBounds;
    FVector rMin = rect.minBounds;
    FVector rMax = rect.maxBounds;

    return min.x < rMax.x && max.x > rMin.x && min.y < rMax.y && max.y > rMin.y;
}

bool FRect::IsPointInsideRect(const FVector &point) const {

    return point.x >= minBounds.x && point.x <= maxBounds.x && point.y >= minBounds.y && point.y <= maxBounds.y;
}

FVector FRect::GetCenter() const {
    return (maxBounds + minBounds) * 0.5f;
}

void from_json(const json &j, FRect &rect) {
    j.at("position").get_to(rect.position);
    j.at("size").get_to(rect.size);
    rect.maxBounds = rect.position + rect.size;
    rect.minBounds = rect.position;
}

FName::FName(const std::string& key)
{
    this->key = key;
    hash = StringToHash(key);
}

std::uint64_t FName::StringToHash(const std::string& key)
{
    if (key.empty()) return 0;

    std::uint64_t hash = 5381;
    for (char c : key)
    {
        hash = ((hash << 5) + hash) + c; // hash * 33 + c
    }
    return hash;
}

float EHMath::MoveTowards(float current, float target, float delta) {
    if (std::abs(target - current) <= delta) return target;
    return current + std::copysign(delta, target - current);
}

void to_json(json& j, const FName& name)
{
    j = json{ {"key", name.GetKey()} };
}

void from_json(const json& j, FName& name)
{
    name = FName(j.get<std::string>());
}