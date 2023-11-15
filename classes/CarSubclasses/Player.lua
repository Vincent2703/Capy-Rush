Player = Car:extend("Player")

function Player:init(x, y, textureName, speed)
    Player.super.init(self, x, y, textureName, speed)
end

function Player:move(dt)
    local boost = false
    local speed = self.speed
    
    if input.state.actions.boost then
        speed = self.boostSpeed
        boost = false
    end

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

    self.x, self.y = self.collider:getX()-self.widthCar/2, self.collider:getY()-self.heightCar/2

    self.anim:update(dt)
end