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
    targetVelX, targetVelY = self:manageTrajectory(targetVelX, targetVelY)

    velX = accX * targetVelX + (1 - accX) * velX

    velY = accY * targetVelY + (1 - accY) * velY

    local velX, velY, goalX, goalY = self:manageCollisions(velX, velY, dt)

    local filter = function(item, other) return self:filterColliders(item, other) end
    local actualX, actualY, cols, len = gameState.states["InGame"].world:move(self, goalX, goalY, filter)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    self.anim:update(dt)
end

function Police:checkBadDriver()
    local watchZone = {xA=self.x-50, yA=self.y-100, xB=self.x+self.widthCar+100, yB=self.y+self.heightCar+200}
    local inGame = gameState.states["InGame"]
    local player = inGame.player

    return not self.inPursuit and 
    (
        (inGame.ejection and 
        inGame.ejection.x >= watchZone.xA and inGame.ejection.x <= watchZone.xB and inGame.ejection.y >= watchZone.yA and inGame.ejection.y <= watchZone.yB) 
    or 
        (player and player.currPathDir == self.direction and player.collidesCar and 
        player.x >= watchZone.xA and player.x <= watchZone.xB and player.y >= watchZone.yA and player.y <= watchZone.yB)
    )
end

function Police:startPursuit()
    self.inPursuit = true
    self.currMaxSpeed = self.maxSpeed
    if direction == "left" then 
        self.direction = "right"
        self.currMaxSpeed = -self.currMaxSpeed
    end
    --self.velocity.y = self.currMaxSpeed
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