FuelGauge = UI:extend("FuelGauge")

function FuelGauge:init(x, y, width, height, visible, player)
    FuelGauge.super.init(self, x, y, width, height, visible, player)
    self.player = player
    self.fuel = player.fuel
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