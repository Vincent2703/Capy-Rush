GameState = class("GameState")

function GameState:init()
    self.states = {
        inGame = InGame(),
        pause = Pause(),
    }
    self.currentState = nil
end

function GameState:setState(stateName)
    self.currentState = self.states[stateName]
end

function GameState:getCurrentStateClassName()
    return self.currentState.className
end

function GameState:isCurrentState(stateName)
    return self:getCurrentStateClassName() == stateName
end