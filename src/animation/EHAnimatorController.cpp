#include "EHAnimatorController.h"
#include "core/EHGameInstance.h"


FAnimatorController::FAnimatorController() : startClip(FName("")) {
    spriteMetaPath = FName("");
    animationMap = std::unordered_map<FName, FAnimationClip>();
    parameterValues = std::unordered_map<FName, FParameterValue>();
    frame = 0;
    currentClip = FAnimationClip();
    actor = nullptr;
}

void FAnimatorController::TickController(float) {
    sol::table state = stateMachineTable[currentClip.clipName.GetKey()];
    if (state.valid()) {
        sol::protected_function tickFunction = state["tick"];
        if (tickFunction.valid()) {
            sol::protected_function_result result = tickFunction(state, actor, frame);
            if (result.valid()) {
                if (result.get_type() == sol::type::string) {
                    // If we get a string result it will tell us that we need to change to a new state
                    SetAnimationClip(FName(result.get<std::string>()));
                    return;
                }
            }
        }
    }
    frame++;
}

bool FAnimatorController::GetAnimationClip(const FName &animName, FAnimationClip &outAnimClip) const{
    if (!animationMap.contains(animName)) {
        return false;
    }
    outAnimClip = animationMap.at(animName);
    return true;
}

void FAnimatorController::InitializeAnimationClips(EHActor* actr) {
    this->actor = actr;
    EHLuaScriptSystem* luaScripting = EHGameInstance::GetInstance()->GetLuaScriptSystem();
    if (!luaScripting) {
        std::cout << "InitializeAnimationClips() - luaScripting is nullptr" << std::endl;
        return;
    }
    luaScripting->LoadTable(stateMachineAsset);
    stateMachineTable = luaScripting->GetTable(stateMachineAsset);
    SetAnimationClip(startClip);
}

void FAnimatorController::SetBool(const FName& id, bool value) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].bValue = value;
}

void FAnimatorController::SetInt(const FName& id, int value) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].iValue = value;
}

void FAnimatorController::SetFloat(const FName& id, float value) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].fValue = value;
}

void FAnimatorController::SetTrigger(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].bValue = true;
}

void FAnimatorController::ResetTrigger(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return;
    }
    parameterValues[id].bValue = false;
}

bool FAnimatorController::GetBool(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return false;
    }
    return parameterValues[id].bValue;
}

int FAnimatorController::GetInt(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return 0;
    }
    return parameterValues[id].iValue;
}

float FAnimatorController::GetFloat(const FName& id) {
    if (!parameterValues.contains(id)) {
        std::cout << "Could not find parameter with key: " << id.GetKey() << std::endl;
        return 0.f;
    }

    return parameterValues[id].fValue;
}

void to_json(nlohmann::json &j, const FAnimatorController &controller) {
    j = {{"spriteMetaPath", controller.spriteMetaPath}, {"startClip", controller.startClip}};
}

void from_json(const nlohmann::json &j, FAnimatorController &controller) {
    j.at("spriteMetaPath").get_to(controller.spriteMetaPath);
    j.at("startClip").get_to(controller.startClip);
    j.at("stateMachineAsset").get_to(controller.stateMachineAsset);

    for (const auto& clip : j.at("clips")) {
        FAnimationClip clipData = clip.get<FAnimationClip>();
        controller.animationMap.insert(std::make_pair(clipData.clipName, clipData));
    }
}

void FAnimatorController::SetAnimationClip(const FName& animName) {
    if (!animationMap.contains(animName)) {
        std::cout << "Failed to retrieve animation with key: " << animName.GetKey() << std::endl;
        return;
    }
    if (currentClip.clipName.isValid()) {
        sol::table oldState = stateMachineTable[currentClip.clipName.GetKey()];
        sol::protected_function exitState = oldState["onExit"];
        if (exitState.valid()) {
            exitState(actor);
        }
    }
    frame = 0;
    currentClip = animationMap.at(animName);
    sol::table state = stateMachineTable[currentClip.clipName.GetKey()];
    if (state.valid()) {
        sol::protected_function enterState = state["onEnter"];
        if (enterState.valid()) {
            enterState(actor);
        }
    }
}
