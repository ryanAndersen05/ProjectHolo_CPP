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
        actor:Sprite():SetSprite("kiara_idle00")
    end,

    tick = function(actor, frame)
        frame = frame % maxFrames
       event = keyFrames[frame]
        if event then
            event(actor)
        end
    end,

    onEnd = function(actor)  end
}

states.kiara_walkf = {
    keyFrames = {
        [0] = function(actor) actor:Sprite("sprite"):SetSprite("kiara_walkf00")  end
    }
}
