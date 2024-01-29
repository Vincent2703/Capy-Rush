GameState = class("GameState")

function GameState:init()
    self.states = {
        InGame = InGame(),
        Pause = Pause(),
        GameOver = GameOver(),
        Options = Options()
    }
    self.currentState = nil
end

function GameState:setState(stateName, start)
    self.currentState = self.states[stateName]
    if start then
        self.currentState:start()
    end
end

function GameState:getCurrentStateClassName()
    return self.currentState.className
end

function GameState:isCurrentState(stateName)
    return self:getCurrentStateClassName() == stateName
end