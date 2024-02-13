Police = Car:extend("Police")

function Police:init(spritesData, maxSpeed, maxHealth, consumptionFactor, direction)
    Police.super.init(self, spritesData, maxSpeed, maxHealth, consumptionFactor)
    self.animations.flashingLights = anim8.newAnimation(self.spritesData.grid("1-4", 3), 0.33)

    self.inPursuit = false

    self.direction = direction
    self.currMaxSpeed = self.maxSpeed*0.7 --Save this value in car
    if direction == "left" then
        self.currMaxSpeed = -self.currMaxSpeed
    end
    self.velocity.y = self.currMaxSpeed*0.7
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

    if self.isExploding then
        velY = math.max(0, math.floor(self.velocity.y*1-dt))
        velX = math.floor(velY/self.maxSpeed*velX)
    end

    local velX, velY, goalX, goalY = self:manageCollisions(velX, velY, dt)

    local filter = function(item, other) return self:filterColliders(item, other) end
    local actualX, actualY, cols, len = gameState.states["InGame"].world:move(self, goalX, goalY, filter)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    self:commonUpdate(dt)
end

function Police:checkBadDriver()
    local watchZone = {xA=self.x-50, yA=self.y-100, xB=self.x+self.widthCar+50, yB=self.y+self.heightCar+100}
    local inGame = gameState.states["InGame"]
    local player = inGame.player

    return not self.inPursuit and 
    (
        (inGame.ejection and 
        inGame.ejection.x >= watchZone.xA and inGame.ejection.x <= watchZone.xB and inGame.ejection.y >= watchZone.yA and inGame.ejection.y <= watchZone.yB) 
    or 
        (player and player.direction == self.direction and player.collidesCar and 
        player.x >= watchZone.xA and player.x <= watchZone.xB and player.y >= watchZone.yA and player.y <= watchZone.yB)
    )
end

function Police:startPursuit()
    self.sfx.policeSiren = soundManager:playSFX("policeSiren", true, self.x, self.y, 10, 250)

    self.currCarAnim = self.animations.flashingLights
    self.inPursuit = true
    self.currMaxSpeed = self.maxSpeed
    if self.direction == "left" then 
        self.direction = "right"
    end
end

function Police:pursuit()
    if self.isExploding then
        self.sfx.policeSiren:stop()
        return 0, 0
    end
    if self.sfx.policeSiren ~= nil then
        self.sfx.policeSiren:setPosition(self.x, self.y)
    end
    local player = gameState.states["InGame"].player
    local velX, velY = 0, self.currMaxSpeed
    if player ~= nil then
        velX = player.x-self.x
        if player.y > self.y then
            velY = self.maxSpeed/2
        end
    end
    return velX, velY
end