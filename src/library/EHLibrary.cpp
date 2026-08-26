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

FVector FVector::operator+(const FVector& vec) const
{
    return {x + vec.x, y + vec.y};
}

FVector FVector::operator-(const FVector& vec) const
{
    return {x - vec.x, y - vec.y};
}

FVector FVector::operator*(float val) const
{
    return {x * val, y * val};
}

FVector FVector::operator/(float val) const
{
    return {x / val, y / val};
}

FVector FVector::operator-() const {
    return {-x, -y};
}

float FVector::Dot(const FVector &vec1, const FVector &vec2) {
    return vec1.x * vec2.x + vec1.y * vec2.y;
}

std::string FVectorInt::to_string() const {
    return "x: " + std::to_string(x) + "y: " + std::to_string(y);
}

bool FRect::isOverlapping(const FRect& rect) const
{
    FVector min = position;
    FVector max = position + size;
    FVector rMin = rect.position;
    FVector rMax = rect.position + rect.size;

    return min.x < rMax.x && max.x > rMin.x && min.y < rMax.y && max.y > rMin.y;
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

void to_json(json& j, const FName& name)
{
    j = json{ {"key", name.GetKey()} };
}

void from_json(const json& j, FName& name)
{
    name = FName(j.get<std::string>());
}