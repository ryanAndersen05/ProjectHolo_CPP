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

    friend void to_json(json& j, const FVector& vec);
    friend void from_json(const json& j, FVector& vec);
};


    struct FVectorInt
{
public:
    static const FVectorInt Zero;
    static const FVectorInt One;

public:
    int x;
    int y;

public:
    FVectorInt(int x, int y) : x(x), y(y) {}
    std::string to_string();

    friend void to_json(json& j, const FVectorInt& vec);
    friend void from_json(const json& j, FVectorInt& vec);
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
    bool isValid() const { return hash != 0; }

public:
    std::string GetKey() const { return key; }
    std::uint64_t GetHash() const { return hash; }
    operator unsigned long() const { return hash; }

    static std::uint64_t StringToHash(const std::string& key);

    friend void to_json(json& j, const FName& name);
    friend void from_json(const json&, FName& name);
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

