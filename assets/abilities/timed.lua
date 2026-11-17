local ability = {}

function ability.onBegin(self, context)
    self.frames = 0
end

function ability.onTick(self, context, deltaTime)
    self.frames = self.frames + 1
    if self.frames >= self.config.durationFrames then
        context:End()
    end
end

return ability
