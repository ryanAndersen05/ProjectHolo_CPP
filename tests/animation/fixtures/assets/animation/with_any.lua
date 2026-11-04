local states = {
    defaultState = "ready", spriteAsset = "",
    parameters = { override = 1, localChange = 1 },
    calls = { any = 0, current = 0, readyExit = 0, winnerEntry = 0,
              loserEntry = 0, anyEntry = 0, anyExit = 0, order = "" }
}
states.any_state = {
    onEnter = function() states.calls.anyEntry = states.calls.anyEntry + 1 end,
    onExit = function() states.calls.anyExit = states.calls.anyExit + 1 end,
    tick = function(self, actor, frame)
        states.calls.any = states.calls.any + 1
        states.calls.order = states.calls.order .. "any,"
        if actor:Animator():GetBool("override") then return "winner" end
    end
}
states.ready = {
    tick = function(self, actor, frame)
        states.calls.current = states.calls.current + 1
        states.calls.currentFrame = frame
        states.calls.order = states.calls.order .. "current,"
        if actor:Animator():GetBool("localChange") then return "loser" end
    end,
    onExit = function() states.calls.readyExit = states.calls.readyExit + 1 end
}
states.winner = {
    onEnter = function() states.calls.winnerEntry = states.calls.winnerEntry + 1 end,
    tick = function(self, actor, frame) states.calls.winnerFrame = frame end
}
states.loser = { onEnter = function() states.calls.loserEntry = states.calls.loserEntry + 1 end }
return states
