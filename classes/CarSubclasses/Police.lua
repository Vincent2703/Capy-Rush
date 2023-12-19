Police = Car:extend("Police")

function Police:init(textureName, widthCar, heightCar, maxSpeed, maxHealth, consumptionFactor, direction)
    Police.super.init(self, textureName, widthCar, heightCar, maxSpeed, maxHealth, consumptionFactor)
    self.inPursuit = false

    self.direction = direction
    self.currMaxSpeed = self.maxSpeed/2
    if direction == "left" then
        self.currMaxSpeed = -self.currMaxSpeed
    end
    self.velocity.y = self.currMaxSpeed
end

function Police:update(dt)
    if not self.inPursuit and self:checkBadDriver() then
        self:startPursuit()
    end

    local accX = self.accX
    local accY = self.accY

    local velX, velY = self.velocity.x, self.velocity.y

    local targetVelX, targetVelY = 0, self.currMaxSpeed
    if self.inPursuit then
        targetVelX, targetVelY = self:pursuit()
    end
    targetVelX = self:avoidObstacles(targetVelX)

    velX = accX * targetVelX + (1 - accX) * velX

    velY = accY * targetVelY + (1 - accY) * velY

    local velX, velY, goalX, goalY, health = self:preMove(velX, velY, dt)
    self.health = health

    local filter = function(item, other) return self:filterColliders(item, other) end
    local actualX, actualY, cols, len = gameState.states["InGame"].world:move(self, goalX, goalY, filter)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    self.anim:update(dt)
end

function Police:checkBadDriver()
    local watchZone = {xA=self.x-100, yA=self.y-200, xB=self.x+100, yB=self.y+200}
    local inGame = gameState.states["InGame"]
    local player = inGame.player

    return not self.inPursuit and
      (player ~= nil and player.currPathDir == self.direction) and
      watchZone.xA <= player.x and player.x <= watchZone.xB and 
      watchZone.yA <= player.y and player.y <= watchZone.yB and
      ((inGame.eject and inGame.ejection.landOn > 0) or player.collidesCar)
end

function Police:startPursuit()
    self.inPursuit = true
    self.currMaxSpeed = self.maxSpeed
    if direction == "left" then
        self.currMaxSpeed = -self.currMaxSpeed
    end
    self.velocity.y = self.currMaxSpeed
end

function Police:pursuit()
    local player = gameState.states["InGame"].player
    local velX, velY = 0, self.currMaxSpeed
    if player ~= nil then
        velX = player.x-self.x
        if player.y < self.y then
            velY = velY/2
        end
    end
    return velX, velY
end