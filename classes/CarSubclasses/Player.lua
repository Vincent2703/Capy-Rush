Player = Car:extend("Player")

function Player:init(x, y, textureName, speed, consumptionFactor)
    Player.super.init(self, x, y, textureName, speed, consumptionFactor)
    self.boostSpeed = speed*1.5
    self.fuel = 100

    self.currentSpeed = speed
end

function Player:move(dt)
    local speed = self.currentSpeed
    
    if self.fuel >= 1 and input.state.actions.boost and not input.state.actions.brake then
        speed = self.boostSpeed
    elseif self.fuel < 1 then
        self.currentSpeed = math.max(0, math.floor(speed - 80*dt))
    end

    self.fuel = math.max(0, tonumber(string.format("%.2f", self.fuel - (speed/10000)*self.consumptionFactor)))

    local vx, vy = 0, speed
    if input.state.actions.right then
		vx = speed
		self.anim = self.animations.right
	end
	if input.state.actions.left then
		vx = -speed
		self.anim = self.animations.left
	end
	if input.state.actions.brake then
		vy = speed*0.5
		self.anim = self.animations.brake
	end

    self.collider:setLinearVelocity(vx, vy)

    self.x, self.y = math.floor(self.collider:getX()-self.widthCar/2), math.floor(self.collider:getY()-self.heightCar/2)

    self.anim:update(dt)
end