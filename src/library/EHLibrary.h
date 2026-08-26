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

    FVector operator+(const FVector& vec) const;
    FVector operator-(const FVector& vec) const;
    FVector operator*(float val) const;
    FVector operator/(float val) const;
    FVector operator-() const;

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
public:
    FVector position;
    FVector size;

public:
    FRect() : position(FVector::Zero), size(FVector::Zero) {}
    FRect(const FVector& position, const FVector& size) : position(position), size(size) {}

    [[nodiscard]] bool isOverlapping(const FRect& rect) const;

};
NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(FRect, position, size)

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
    [[nodiscard]] bool isValid() const { return hash != 0; }

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

