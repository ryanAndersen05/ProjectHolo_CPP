#pragma once
#include<string>

struct FVector
{
public:
    static const FVector Zero;
    static const FVector One;
    static const FVector Right;
    static const FVector Left;
    static const FVector Up;
    static const FVector Down;

public:
    float x;
    float y;

public:
    FVector(float x, float y) : x(x), y(y) {};
    FVector() : x(0), y(0) {}

    float getMagnitude() const;
    float getMagnitudeSquared() const;
    FVector getNormal() const;
    void normalize();

    FVector operator+(const FVector& vec) const;
    FVector operator-(const FVector& vec) const;
    FVector operator*(float val) const;
    FVector operator/(float val) const;
};

struct FRect
{
public:
    FVector position;
    FVector size;

public:
    FRect() : position(FVector::Zero), size(FVector::Zero) {}
    FRect(const FVector& position, const FVector& size) : position(position), size(size) {}

    bool isOverlapping(const FRect& rect) const;
};