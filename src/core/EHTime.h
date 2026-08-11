
class EHTime {
private:
    static float DeltaTime;
    static float FixedDeltaTime;
    static float TimeScale;
public:
    static float constexpr FrameTime = 1.f / 60.0f;
    static float GetDeltaTime() {return DeltaTime;}
    static float GetFixedDeltaTime() {return FixedDeltaTime;}
    static float GetTimeScale() {return TimeScale;}

    static void SetDeltaTime(float deltaTime) {EHTime::DeltaTime = deltaTime;}
    static void SetFixedDeltaTime(float fixedDeltaTime) {EHTime::FixedDeltaTime = fixedDeltaTime;}
    static void SetTimeScale(float timeScale) {EHTime::TimeScale = timeScale;}
};