local states = { defaultState = "ready", spriteAsset = "", parameters = {}, calls = { current = 0 } }
states.ready = {
    tick = function(self, actor, frame)
        states.calls.current = states.calls.current + 1
        states.calls.currentFrame = frame
    end
}
return states
