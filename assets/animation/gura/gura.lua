local states = {}

states.gura_idle = {
    keyFrames =
    {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle00")  end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle01")  end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle02")  end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle03")  end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle04")  end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle05")  end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle06")  end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle07")  end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle08")  end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("gura_idle09")  end
    },
    maxFrames = 50,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_idle00")
    end,
    tick = function(self, actor, frame)
        local adjustedFrame = frame % self.maxFrames
        local event = self.keyFrames[adjustedFrame]
        if event then
            event(actor)
        end
    end
}

states.gura_walkf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf00")  end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf01")  end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf02")  end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf03")  end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf04")  end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkf05")  end
    },
    maxFrames = 36,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkf00")
    end,
    tick = function(self, actor, frame)
        local adjustedFrame = frame % self.maxFrames
        local event = keyFrames[adjustedFrame]
        if event then
            event(actor)
        end
    end
}

states.gura_walkb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb00")  end,
        [6] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb01")  end,
        [12] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb02")  end,
        [18] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb03")  end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb04")  end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("gura_walkb05")  end,
    },
    maxFrames = 36,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("gura_walkb00")
    end,
    tick = function(self, actor, frame)
        local adjustedFrame = frame % self.maxFrames
        local event = keyFrames[adjustedFrame]
        if event then
            event(actor)
        end
    end
}

return states