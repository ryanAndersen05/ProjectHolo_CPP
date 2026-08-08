#include "EHLibrary.h"
#include <cmath>

const FVector FVector::Zero = FVector(0.f, 0.f);
const FVector FVector::One = FVector(1.f, 1.f);
const FVector FVector::Right = FVector(1.f, 0.f);
const FVector FVector::Left = FVector(-1.f, 0.f);
const FVector FVector::Up = FVector(0.f, 1.f);
const FVector FVector::Down = FVector(0.f, -1.f);

const FVectorInt FVectorInt::Zero = FVectorInt(0, 0);
const FVectorInt FVectorInt::One = FVectorInt(1, 1);

float FVector::getMagnitude() const
{
    return sqrtf(x * x + y * y);
}

float FVector::getMagnitudeSquared() const
{
    return x * x + y * y;
}

FVector FVector::getNormal() const
{
    const float mag = getMagnitude();
    if (mag == 0.f) return FVector::Zero;
    return FVector(x / mag, y / mag);
}

void FVector::normalize()
{
    float mag = getMagnitude();
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
    return FVector(x + vec.x, y + vec.y);
}

FVector FVector::operator-(const FVector& vec) const
{
    return FVector(x - vec.x, y - vec.y);
}

FVector FVector::operator*(float val) const
{
    return FVector(x * val, y * val);
}

FVector FVector::operator/(float val) const
{
    return FVector(x / val, y / val);
}

void to_json(json& j, const FVector& vec)
{
    j = json{ {"x", vec.x}, {"y", vec.y} };
}

void from_json(const json & j, FVector& vec)
{
    j.at("x").get_to(vec.x);
    j.at("y").get_to(vec.y);
}

std::string FVectorInt::to_string()
{
    return "x: " + std::to_string(x) + "y: " + std::to_string(y);
}

void to_json(json& j, const FVectorInt& vec)
{
    j = json{ {"x", vec.x}, {"y", vec.y} };
}

void from_json(const json& j, FVectorInt& vec)
{
    j.at("x").get_to(vec.x);
    j.at("y").get_to(vec.y);
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

unsigned long FName::StringToHash(const std::string& key)
{
    if (key.empty()) return 0;

    unsigned long hash = 5381;
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