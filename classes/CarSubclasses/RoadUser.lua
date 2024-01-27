RoadUser = Car:extend("RoadUser")

function RoadUser:init(spritesData, maxSpeed, maxHealth, consumptionFactor, direction)
    RoadUser.super.init(self, spritesData, maxSpeed, maxHealth, consumptionFactor)
    self.direction = direction
    self.currMaxSpeed = self.maxSpeed/2
    if direction == "left" then
        self.currMaxSpeed = -self.currMaxSpeed
    end
    self.velocity.y = self.currMaxSpeed
end

function RoadUser:update(dt)
    local accX = self.accX
    local accY = self.accY

    local velX, velY = self.velocity.x, self.velocity.y

    local targetVelX, targetVelY = self:manageTrajectory()

    -- Smoothly adjust velocity towards the target
    velX = accX*targetVelX - accX*velX + velX
    -- Update y-velocity
    velY = accY * targetVelY + (1 - accY) * velY

    if self.destructionState ~= "none" then
        velY = math.max(0, math.floor(self.velocity.y*1-dt))
        velX = math.floor(velY/self.maxSpeed*velX)
    end

    local velX, velY, goalX, goalY = self:manageCollisions(velX, velY, dt)

    -- Move player using the velocity

    local filter = function(item, other) return self:filterColliders(item, other) end
    local actualX, actualY, cols, len = gameState.states["InGame"].world:move(self, goalX, goalY, filter)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    self.currCarAnim:update(dt)
    self:manageEffectsAnim(dt)
end