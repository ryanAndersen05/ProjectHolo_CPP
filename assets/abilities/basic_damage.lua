local ability = {}

function ability.canActivate(self, context, target)
    if not target then return false end
    local defender = target:Abilities()
    return defender and defender:GetAttribute("health") ~= nil
        and not defender:HasTag("invulnerable")
end

function ability.onBegin(self, context)
    local defender = context:Target():Abilities()
    defender:ApplyEffect(self.config.damageEffect, context:Actor())
    context:End()
end

return ability
