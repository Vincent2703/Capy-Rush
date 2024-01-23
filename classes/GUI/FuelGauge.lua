FuelGauge = class("FuelGauge")

function FuelGauge:init(x, y, width, height, visible)
    self.x, self.y, self.width, self.height, self.visible = x, y, width, height, visible or true
    self.player = gameState.states["InGame"].player --Arg ? Or glob const IG ?
    self.fuel = self.player.fuel
end

function FuelGauge:update()
    self.fuel = self.player.fuel
end

function FuelGauge:draw()
    local widthFuel = math.floor(self.fuel/100*self.width)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(255, 0, 0)
    if widthFuel > 0 then
        love.graphics.rectangle("fill", self.x+1, self.y+1, widthFuel-2, self.height-2)
    end
    love.graphics.setColor(255, 255, 255)
end