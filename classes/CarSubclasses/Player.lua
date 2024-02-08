Player = Car:extend("Player")

function Player:update(dt)
    local inGame = gameState.states["InGame"]
    local accX = 0.06
    local accY = 0.02
    local maxSpeed = self.maxSpeed*inGame.difficulty.speed

    local velX, velY = self.velocity.x, self.velocity.y

    self.fuel = math.max(0, self.fuel - self.consumptionFactor*dt)

    -- Update velocity based on input
    local targetVelX = 0
    if not self.isExploding then
        if input.state.actions.right then
            targetVelX = maxSpeed*input.state.accelerometer.tiltX
        elseif input.state.actions.left then
            targetVelX = -maxSpeed*input.state.accelerometer.tiltX
        end
    end

    -- Smoothly adjust velocity towards the target or cap it
    if targetVelX == 0 and math.abs(self.velocity.x) < 1 then
        velX = 0
    else
        velX = accX*targetVelX - accX*velX + velX
    end    

    -- Update y-velocity
    velY = accY * maxSpeed + (1 - accY) * velY

    if self.fuel <= 0 or self.isExploding then
        velY = math.max(0, math.floor(self.velocity.y*1-dt))
        velX = math.floor(velY/maxSpeed*velX)
    end

    -- Move player using the velocity

    local velX, velY, goalX, goalY, collidesCar = self:manageCollisions(velX, velY, dt)
    self.collidesCar = collidesCar

    local filter = function(item, other) 
        if other.isPath then
            self.direction = other.direction
        end
        return self:filterColliders(item, other) 
    end
    local actualX, actualY, cols, len = inGame.world:move(self, goalX, goalY, filter)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    self:commonUpdate(dt)
    
    love.audio.setPosition(self.x, self.y, 0)
end
