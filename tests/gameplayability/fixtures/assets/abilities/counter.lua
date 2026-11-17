local ability = { uninitialized = 0 }

function ability.onInitialize(self, context)
    self.frames = 0
end

function ability.onBegin(self, context)
    if self.config.failBegin then error("Intentional begin failure") end
    self.frames = 0
end

function ability.onEnd(self, context)
    if context:Target() then
        assert(context:Target():Abilities():GetAttribute("health") ~= nil)
    end
end

function ability.onTick(self, context, deltaTime)
    if self.config.failTick then error("Intentional callback failure") end
    self.frames = self.frames + 1
    context:System():SetBaseAttribute("ticks", self.frames)
    if self.frames >= self.config.endFrames then context:End() end
end

function ability.onUninitialize(self, context)
    -- Shared only as test instrumentation; gameplay state lives in self.
    ability.uninitialized = ability.uninitialized + 1
    assert(context:Actor():Abilities() ~= nil)
end

return ability
