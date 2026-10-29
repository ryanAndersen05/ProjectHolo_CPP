local states = {
    defaultState = "ready",
    spriteAsset = "",
    parameters = {}
}

states.ready = {
    onEnter = function(actor)
        -- The component must be available during initial animation entry.
        local boxes = actor:Hitbox()
        assert(boxes and boxes:HasHitbox("attack"))
        assert(boxes:IsActive("attack") == false)
        assert(boxes:IsActive("body") == true)
        assert(boxes:SetPosition("body", -0.5, 0.25))
    end,
    tick = function(self, actor, frame)
        local boxes = actor:Hitbox()
        if frame == 1 then
            assert(boxes:SetPosition("attack", 2, 3))
            assert(boxes:SetSize("attack", 4, 5))
            assert(boxes:SetActive("attack", true))
        elseif frame == 2 then
            assert(boxes:SetBounds("attack", 6, 7, 8, 9))
        elseif frame == 3 then
            return "done"
        end
    end,
    onExit = function(actor)
        assert(actor:Hitbox():SetActive("attack", false))
    end
}

states.done = {}

states.persistent = {
    onEnter = function(actor)
        assert(actor:Hitbox():SetActive("attack", true))
    end,
    tick = function(self, actor, frame)
        return "done"
    end
    -- No onExit: the engine must preserve activation across this transition.
}

states.CheckBindings = function(actor, emptyActor)
    local boxes = actor:Hitbox()
    assert(actor:Hitbox("hitbox") == boxes)
    assert(actor:Hitbox("alternate") ~= nil)
    assert(actor:Hitbox("animator") == nil)
    assert(actor:Hitbox("missing") == nil)
    assert(emptyActor:Hitbox() == nil)
    assert(boxes:HasHitbox("attack") and not boxes:HasHitbox("missing"))
    assert(boxes:GetType("attack") == HitboxType.Hitbox)
    assert(boxes:GetType("body") == HitboxType.Hurtbox)
    assert(boxes:IsActive("attack") == false)
    assert(boxes:GetType("missing") == nil)
    assert(boxes:IsActive("missing") == nil)
    assert(select("#", boxes:GetPosition("missing")) == 1)
    assert(boxes:GetPosition("missing") == nil)
    assert(boxes:GetSize("missing") == nil)
    assert(boxes:GetLocalBounds("missing") == nil)
    assert(boxes:GetWorldBounds("missing") == nil)

    local x, y = boxes:GetPosition("attack")
    local w, h = boxes:GetSize("attack")
    assert(x == 1 and y == 2 and w == 3 and h == 4)
    x, y, w, h = boxes:GetLocalBounds("attack")
    assert(x == 1 and y == 2 and w == 3 and h == 4)
    x, y, w, h = boxes:GetWorldBounds("attack")
    assert(x == 1 and y == 2 and w == 3 and h == 4)

    assert(not boxes:SetActive("missing", true))
    assert(not boxes:SetPosition("missing", 1, 2))
    assert(not boxes:SetSize("missing", 3, 4))
    assert(not boxes:SetBounds("missing", 1, 2, 3, 4))
    assert(not boxes:SetSize("attack", -1, 4))
    assert(not boxes:SetPosition("attack", math.huge, 2))
    assert(not boxes:SetBounds("attack", 1, 2, 3, 0 / 0))
    x, y, w, h = boxes:GetLocalBounds("attack")
    assert(x == 1 and y == 2 and w == 3 and h == 4)

    assert(boxes:SetBounds("attack", -2, -3, 0, 0))
    x, y, w, h = boxes:GetLocalBounds("attack")
    assert(x == -2 and y == -3 and w == 0 and h == 0)
    assert(boxes:SetActive("attack", true))
    assert(actor:Hitbox("alternate"):IsActive("attack") == false)
    assert(boxes:SetActive("attack", false))
    assert(boxes:SetBounds("attack", 1, 2, 3, 4))
end

return states
