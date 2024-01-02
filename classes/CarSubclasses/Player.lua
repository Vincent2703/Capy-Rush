Player = Car:extend("Player")

--[[function Player:init(textureName, widthCar, heightCar, maxSpeed, maxHealth, consumptionFactor)
    Player.super.init(self, textureName, widthCar, heightCar, maxSpeed, maxHealth, consumptionFactor)
end--]]

function Player:update(dt)
    local accX = 0.04
    local accY = 0.02

    local velX, velY = self.velocity.x, self.velocity.y

    self.fuel = math.max(0, self.fuel - self.consumptionFactor*dt)

    -- Update velocity based on input
    local targetVelX = 0
    if input.state.actions.right then
        targetVelX = self.maxSpeed*input.state.joystick.inclinXRatio
        self.anim = self.animations.right
    elseif input.state.actions.left then
        targetVelX = -self.maxSpeed*input.state.joystick.inclinXRatio
        self.anim = self.animations.left
    end

    -- Smoothly adjust velocity towards the target
    velX = accX*targetVelX - accX*velX + velX

    -- Update y-velocity
    velY = accY * self.maxSpeed + (1 - accY) * velY

    if self.fuel <= 0 then
        velY = math.max(0, math.floor(self.velocity.y*1-dt))
        velX = math.floor(velY/self.maxSpeed*velX)
    end

    -- Move player using the velocity

    local velX, velY, goalX, goalY, collidesCar = self:manageCollisions(velX, velY, dt)
    self.collidesCar = collidesCar

    local filter = function(item, other) 
        if other.isPath then
            self.currPathDir = other.direction
        end
        return self:filterColliders(item, other) 
    end
    local actualX, actualY, cols, len = gameState.states["InGame"].world:move(self, goalX, goalY, filter)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    -- Update animation
    self.anim:update(dt)
end
