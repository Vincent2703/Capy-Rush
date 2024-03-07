FuelGauge = class("FuelGauge")

function FuelGauge:init(x, y, width, height, visible)
    self.x, self.y, self.width, self.height, self.visible = x, y, width, height, visible or true
    self.player = gameState.states["InGame"].player --Arg ? Or glob const IG ?
    self.fuel = self.player.fuel

    self.lowAlert = false

    self.timer = 0
    self.blinkDelay = 0.4
    self.sfxLowFuel = nil
end

function FuelGauge:update(dt)
    self.fuel = self.player.fuel
    self.lowAlert = self.fuel <= 25
    if self.lowAlert then
        if self.sfxLowFuel == nil then
            self.sfxLowFuel = soundManager:playSFX("lowFuel")
        end
        self.timer = self.timer < self.blinkDelay and self.timer+dt or 0
    end
end

function FuelGauge:draw()
    local widthFuel = math.floor(self.fuel/100*self.width)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    if widthFuel > 0 then
        local ratio = self.lowAlert and self.timer/self.blinkDelay or 1
        love.graphics.setColor(1, 0, 0, ratio)
        love.graphics.rectangle("fill", self.x+1, self.y+1, widthFuel-2, self.height-2)
        love.graphics.setColor(1, 1, 1, 1)
    end
end