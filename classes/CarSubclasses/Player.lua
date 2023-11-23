Player = Car:extend("Player")

function Player:init(textureName, widthCar, heightCar, speed, consumptionFactor)
    Player.super.init(self, textureName, widthCar, heightCar, speed, consumptionFactor)
    self.boostSpeedMult = 1.5

    self.currentSpeed = speed
end

function Player:move(dt)
    local speed = self.currentSpeed
    
    if self.fuel >= 1 and input.state.actions.boost and not input.state.actions.brake then
        speed = speed*self.boostSpeedMult
    elseif self.fuel < 1 then
        local vx, vy = self.collider:getLinearVelocity()
        self.currentSpeed = math.max(0, math.floor(vy - 80*dt))
        speed = self.currentSpeed
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