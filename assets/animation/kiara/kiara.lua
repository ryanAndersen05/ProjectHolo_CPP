local states = {}

states.kiara_idle = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle00")  end,
        [5] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle01")  end,
        [10] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle02")  end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle03")  end,
        [20] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle04")  end,
        [25] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle05")  end,
        [30] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle06")  end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle07")  end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_idle08")  end
    },
    maxFrames = 45,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_idle00")
    end,
    tick = function(self, actor, frame)
        local adjustedFrame = frame % self.maxFrames
        local event = self.keyFrames[adjustedFrame]
        if event then
            event(actor)
        end
    end
}

states.kiara_walkfstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite():SetSprite("kiara_walkf00")  end
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkf00")
    end,
    tick = function(self, actor, frame)
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
        if frame >= self.maxFrames then
            return "kiara_walkf"
        end
    end
}

states.kiara_walkf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf01")  end,
        [4] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf02")  end,
        [8] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf03")  end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf04")  end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf05")  end,
        [24] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf06")  end,
        [28] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf07")  end,
        [35] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf08")  end,
        [40] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf09")  end,
        [45] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf10")  end,
        [50] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf11")  end
    },
    maxFrames = 55,
    onEnter = function(actor)
        actor:Sprite():SetSprite("kiara_walkf00")
    end,
    tick = function(self, actor, frame)
        local adjustedFrame = frame % self.maxFrames;
        local event = self.keyFrames[adjustedFrame]
        if event then
            event(actor)
        end
    end
}

states.kiara_walkbstart = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb00")  end
    },
    maxFrames = 5,
    onEnter = function(actor)
        actor:Sprite("sprite"):SetSprite("kiara_walkb00")
    end,
    tick = function(self, actor, frame)
        local event = self.keyFrames[frame]
        if event then
            event(actor)
        end
        if (frame >= self.maxFrames) then
            return "kiara_walkb"
        end
    end,
}

states.kiara_walkb = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb01")  end,
        [7] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb02")  end,
        [11] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb03")  end,
        [15] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb04")  end,
        [19] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb05")  end,
        [23] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb06")  end,
        [27] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb07")  end,
        [31] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb08")  end,
        [38] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb09")  end,
        [42] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb10")  end,
        [46] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkb11")  end
    },
    maxFrames = 50,
    onEnter = function(actor)

    end,
    tick = function(self, actor, frame)
        local adjustedFrame = frame % self.maxFrames
        local event = self.keyFrames[adjustedFrame]
        if event then
            event(actor)
        end
    end
}

return states