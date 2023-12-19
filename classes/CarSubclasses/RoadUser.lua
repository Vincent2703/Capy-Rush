RoadUser = Car:extend("RoadUser")

function RoadUser:init(textureNameOrModel, widthCar, heightCar, maxSpeed, maxHealth, consumptionFactor, direction)
    RoadUser.super.init(self, textureNameOrModel, widthCar, heightCar, maxSpeed, maxHealth, consumptionFactor)
    self.direction = direction
    self.maxSpeedRoadUser = self.maxSpeed/2
    if direction == "left" then
        self.maxSpeedRoadUser = -self.maxSpeedRoadUser
    end
    self.velocity.y = self.maxSpeedRoadUser
end

function RoadUser:update(dt)
    local accX = self.accX
    local accY = self.accY

    local velX, velY = self.velocity.x, self.velocity.y

    local distTargetX = self:avoidObstacles()

    -- Smoothly adjust velocity towards the target
    velX = accX*distTargetX - accX*velX + velX

    -- Update y-velocity
    velY = accY * self.maxSpeedRoadUser + (1 - accY) * velY

    local velX, velY, goalX, goalY, health = self:preMove(velX, velY, dt)
    self.health = health

    -- Move player using the velocity

    local filter = function(item, other) return self:filterColliders(item, other) end
    local actualX, actualY, cols, len = gameState.states["InGame"].world:move(self, goalX, goalY, filter)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    self.anim:update(dt)
end