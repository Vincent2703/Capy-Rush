RoadUser = Car:extend("RoadUser")

function RoadUser:init(spritesData, maxSpeed, maxHealth, consumptionFactor, direction)
    RoadUser.super.init(self, spritesData, maxSpeed, maxHealth, consumptionFactor)
    self.direction = direction
    self.currMaxSpeed = self.maxSpeed*0.65 --Save this value in Car
    if direction == "left" then
        self.currMaxSpeed = -self.currMaxSpeed
    end
    self.velocity.y = self.currMaxSpeed*0.7

    self.hornCanPlay = math.random() >= 0.6

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

    if self.isExploding then
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

    self:commonUpdate(dt)

    if self.direction == "left" and self.hornCanPlay then
        local inGame = gameState.states["InGame"]
        local player = inGame.player
        if player and player.direction == "left" then
            local filterPlayer = function(item) --Detect the player
                return item.className == "Player"
            end
            local world = inGame.world
            _, len = world:querySegment(self.x-TILEDIM, self.y+self.heightCar, self.x+self.widthCar+TILEDIM*3, self.y+self.heightCar, filterPlayer)
            if len > 0 then --Detects player
                local horns = {"horn1", "horn2"}
                soundManager:playSFX(horns[math.random(#horns)], false, self.x, self.y, 1, 100)
                self.hornCanPlay = false
            end
        end
    end

end