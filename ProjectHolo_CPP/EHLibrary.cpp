#include "EHLibrary.h"
#include <cmath>

const FVector FVector::Zero = FVector(0, 0);
const FVector FVector::One = FVector(1.f, 1.f);
const FVector FVector::Right = FVector(1, 0);
const FVector FVector::Left = FVector(-1, 0);
const FVector FVector::Up = FVector(0, 1);
const FVector FVector::Down = FVector(0, -1);

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

bool FRect::isOverlapping(const FRect& rect) const
{
    FVector min = position;
    FVector max = position + size;
    FVector rMin = rect.position;
    FVector rMax = rect.position + rect.size;

    return min.x < rMax.x && max.x > rMin.x && min.y < rMax.y && max.y > rMin.y;
}