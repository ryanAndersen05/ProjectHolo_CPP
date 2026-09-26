#pragma once
#include<string>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

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
    FVector(const float x, const float y) : x(x), y(y) {};
    FVector() : x(0), y(0) {}

    [[nodiscard]] float GetMagnitude() const;
    [[nodiscard]] float GetMagnitudeSquared() const;
    [[nodiscard]] FVector GetNormal() const;
    void normalize();

    FVector operator+(const FVector& vec) const { return {x + vec.x, y + vec.y}; }
    FVector operator-(const FVector& vec) const { return {x - vec.x, y - vec.y}; }
    FVector operator*(float val) const { return {x * val, y * val}; }
    FVector operator/(float val) const { return {x / val, y / val}; }
    FVector operator-() const { return {-x, -y}; }

    static float Dot(const FVector& vec1, const FVector& vec2);

};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FVector, x, y)


struct FVectorInt
{
public:
    static const FVectorInt Zero;
    static const FVectorInt One;

public:
    int x;
    int y;

public:
    FVectorInt(const int x, const int y) : x(x), y(y) {}
    operator FVector() const { return {static_cast<float>(x), static_cast<float>(y)}; }
    [[nodiscard]] std::string to_string() const;

};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FVectorInt, x, y)

struct FRect
{
private:
    FVector position;
    FVector size;
    FVector maxBounds;
    FVector minBounds;

public:
    FRect(const FVector& position, const FVector& size);
    FRect() : FRect(FVector::Zero, FVector::Zero) {}

    [[nodiscard]] bool IsOverlapping(const FRect& rect) const;
    [[nodiscard]] bool IsPointInsideRect(const FVector& point) const;
    [[nodiscard]] FVector GetCenter() const;

    friend void from_json(const json& j, FRect& rect);
};

struct FName
{
private:
    std::string key;
    std::uint64_t hash;

public:
    FName() : hash(0) {}
    FName(const std::string& key);

    bool operator==(const FName& name) const { return hash == name.hash; }
    bool operator!=(const FName& name) const { return hash != name.hash; }
    [[nodiscard]] bool IsValid() const { return hash != 0; }

public:
    [[nodiscard]] const std::string& GetKey() const { return key; }
    [[nodiscard]] std::uint64_t GetHash() const { return hash; }
    operator unsigned long() const { return hash; }

    static std::uint64_t StringToHash(const std::string& key);

    friend void to_json(json& j, const FName& name);
    friend void from_json(const json&, FName& name);
};


class EHMath {
public:
    static int SafeMod(const int x, const int m) { return (x % m + m) % m; }
    static float MoveTowards(float current, float target, float delta);
};

namespace std
{
    template<>
    struct hash<FName>
    {
        std::size_t operator()(const FName& name) const
        {
            return name.GetHash();
        }
    };
};

