Car = class("Car")

function Car:init(spritesData, maxSpeed, maxHealth, consumptionFactor, motorPosY, isPolice)
    self.spritesData = spritesData
    self.widthCar, self.heightCar = self.spritesData.widthSprite, self.spritesData.heightSprite

    self.spritesheet = self.spritesData.spritesheet
    self.animations = {}

    self.animations.normal = anim8.newAnimation(self.spritesData.grid(1, 1), 1) -- Anim useful ?
    self.currCarAnim = self.animations.normal

    self.animations.smoke = {
        std = anim8.newAnimation(globalAssets.animations.smoke.grid("1-9", 1), 0.08, function() self.smokeOffsetY = 0 end)
    }

    self.animations.fire = {
        front = anim8.newAnimation(globalAssets.animations.fire.grid("1-15", 1), 0.1),
        left = anim8.newAnimation(globalAssets.animations.fire.grid("1-15", 2), 0.1),
        right = anim8.newAnimation(globalAssets.animations.fire.grid("1-15", 3), 0.1)
    }

    self.animations.explosion = {
        std = anim8.newAnimation(globalAssets.animations.explosion.grid("1-22", 1), 0.09, function() self:destroy() end) 
    }

    self.currFireAnim = {name=nil, anim=nil}
    self.explosionAnim = self.animations.explosion.std

    self.x, self.y = 0, 0
    self.maxSpeed = maxSpeed
    self.velocity = {x=0, y=0}
    self.accX = 0.18
    self.accY = 0.01
    self.fuel = 100
    self.consumptionFactor = consumptionFactor
    self.motorPosY = motorPosY or 0
    self.maxHealth = maxHealth
    self.health = maxHealth

    self.lastCollision = 0
    self.delayDamage = 1

    self.isPolice = isPolice or false

    self.isSmoking = false
    self.smokeOffsetY = 0
    self.onFire = false

    --To refactorize
    self.isExploding = false
    self.startExplosionSFX = false
    self.opacity = 1

    self.sfx = {
        fire = nil,
        wind = nil
    }

    self.isCar = true
end

function Car:manageCollisions(velX, velY, dt)
    -- Update the last collision time
    self.lastCollision = self.lastCollision + dt

    -- Calculate the goal position based on velocity and time
    local goalX, goalY = self.x + velX*dt, self.y - velY*dt
    -- Round the goal position to two decimal places
    goalX, goalY = tonumber(string.format("%.2f", goalX)), tonumber(string.format("%.2f", goalY))

    -- To use the filterColliders
    local filter = function(item, other) return self:filterColliders(item, other) end

    -- Check for collisions in the game world
    local actualX, actualY, cols, len = gameState.states["InGame"].world:check(self, goalX, goalY, filter)

    -- Flag to track if the player collides with a car
    local playerCollidesCar = false

    -- Check if there are collisions
    if len > 0 then
        local collision = cols[1]
        local other = collision.other
        local normal = collision.normal

        -- Reset the target X position <-- TO REMOVE ?
        self.targetX = nil

        -- Check if the colliding object is a RoadUser or Police and the current car is the player
        if (other.className == "RoadUser" or other.className == "Police") and self.className == "Player" then
            playerCollidesCar = true

            -- Check if enough time has passed since the last collision and the velocity is high enough
            if self.className == "Player" and self.lastCollision >= self.delayDamage and self.velocity.y >= 0.15 * self.maxSpeed then
                -- Reduce health of both the player and the other car
                other.health = other.health-1
                self.health = self.health-1
                -- Reset the collision timer
                self.lastCollision = 0
                soundManager:playSFX("crash2")
            end

            -- Adjust velocities based on the collision
            if normal.x ~= 0 then
                velX, velY = velX / 2, velY * 0.75
                other.velocity.x = other.velocity.x + self.velocity.x / 2
                other.velocity.y = math.max(velY, other.velocity.y / 2)
            elseif normal.y == 1 then
                velX, velY = velX / 2, velY / 2
                other.velocity.y = other.velocity.y + self.velocity.y / 3
            end
            --other.onFire = other.health == 1
        -- Check if the colliding item is an obstacle
        elseif other.isObstacle then

            -- Adjust velocities based on the collision
            if normal.x ~= 0 then
                velX, velY = 0, velY / 2
            elseif normal.y == 1 then
                velX, velY = velX / 2, 0
            end

            -- Check if the current car is the player, enough time has passed since the last collision, and the velocity is high enough
            if self.className == "Player" and self.velocity.y >= 0.15 * self.maxSpeed and self.lastCollision >= self.delayDamage then
                -- Reduce the player's health and reset the collision timer
                self.health = self.health-1
                self.lastCollision = 0
                soundManager:playSFX("collisionObstacle")
            end
        end

        --To put elsewhere ?
        --[[self.onFire = self.health == 1
        other.onFire = other.health == 1
        self.isExploding = (self.health <= 0) and "currently" or "none"
        other.isExploding = (other.health <= 0) and "currently" or "none"--]]
    end

    return velX, velY, goalX, goalY, playerCollidesCar
end



function Car:updatePosition(x, y)
    self.x, self.y = x, y
    gameState.states["InGame"].world:update(self, x, y)
    self.opacity = 1 -- temp fix
end

function Car:castToPlayer(x, y)
    local player = self:cast(Player)

    player.currentSpeed = self.maxSpeed
    gameState.states["InGame"].world:add(player, player.x, player.y, player.widthCar, player.heightCar)
    player:updatePosition(x, y)
    return player
end

function Car:castToRoadUser(x, y, direction)
    local roadUser = RoadUser(self.spritesData, self.maxSpeed, self.maxHealth, self.consumptionFactor, direction)
    roadUser.direction = direction
    gameState.states["InGame"].world:add(roadUser, roadUser.x, roadUser.y, roadUser.widthCar, roadUser.heightCar)
    roadUser:updatePosition(x, y)
    return roadUser
end

function Car:castToPolice(x, y, direction)
    local police = Police(self.spritesData, self.maxSpeed, self.maxHealth, self.consumptionFactor, direction)
    police.direction = direction
    gameState.states["InGame"].world:add(police, police.x, police.y, police.widthCar, police.heightCar)
    police:updatePosition(x, y)
    return police
end

function Car:destroy()
    local posX, posY = self.y, self.x
    local inGame = gameState.states["InGame"]
    local cars = inGame.cars
    
    if self.className == "Player" then
        inGame.player = nil
    else
        for i, v in ipairs(cars) do
            if v == self then
                table.remove(cars, i)
                break
            end
        end
    end

    inGame.world:remove(self) 
end

function Car:switchCar(carToSwitch)
    local inGame = gameState.states["InGame"]

    local speed = self.maxSpeed*0.6
    local oldCar = self:cast(RoadUser)
    oldCar.currMaxSpeed = speed

    local player = carToSwitch:cast(Player)
    player.direction = "right"

    inGame.UI["fuelGauge"].player = player -- optimize

    local cars = inGame.cars
    for i = #cars, 1, -1 do
        if cars[i] == carToSwitch then
            table.remove(cars, i) -- Remove new car from the list of roadUsers/Police
            break
        end
    end
    oldCar.direction = "right"
    table.insert(inGame.cars, oldCar)

    return player
end


function Car:filterColliders(item, other)
    if other.isObstacle then 
        return "slide" 
    elseif other.isCar then
        return "bounce"
    else
        return nil
    end
end

function Car:manageTrajectory(velX, velY)
    local velX = velX or 0
    local velY = velY or self.currMaxSpeed
    if self.direction == "left" then
        velY = velY*0.4
    end

    local inGame = gameState.states["InGame"]
    local world = inGame.world
    
    local filterCars = function(item) --Detect cars, minus the player
        return (item.className == "RoadUser" or item.className == "Police") and self ~= item
    end

    local filterCarsObstacles = function(item) --Detect cars (including Player) and obstacles
        return (item.isObstacle or item.className == "RoadUser" or item.className == "Police" or item.className == "Player") and self ~= item --Instanceof Car
    end

    local filterPaths = function(item) --Detect paths
        return item.isPath and item.direction == self.direction
    end

    local queryTopPathsY
    local queryTopCarsY
    if self.direction == "right" then
        queryTopPathsY = self.y-self.heightCar*4
        queryTopCarsY = self.y-self.heightCar*2.5
    else
        queryTopPathsY = self.y+self.heightCar*5
        queryTopCarsY = self.y+self.heightCar*3.5
    end
    local _, lenTopPaths = world:queryPoint(self.x+self.widthCar/2, queryTopPathsY, filterPaths)
    local _, lenTopCars = world:queryRect(self.x, queryTopCarsY, self.widthCar, self.heightCar*2, filterCars)

    if (lenTopPaths == 0 or lenTopCars > 0) and self.targetX == nil then -- No path or car(s) and no target already defined

        local _, lenLeftCarsObstacles = world:queryRect(self.x-TILEDIM, self.y-self.heightCar*2, TILEDIM*0.75, self.heightCar*4, filterCarsObstacles)
        local _, lenRightCarsObstacles = world:queryRect(self.x+self.widthCar+TILEDIM*0.25, self.y-self.heightCar*2, TILEDIM*0.75, self.heightCar*4, filterCarsObstacles)

        local yNextPaths = 0
        if self.direction == "right" then 
            yNextPaths = self.y-TILEDIM*3
        else
            yNextPaths = self.y+self.heightCar+TILEDIM*3
        end

        local leftPaths, lenLeftPaths = world:queryPoint(self.x-TILEDIM/2, yNextPaths, filterPaths) 
        local rightPaths, lenRightPaths = world:queryPoint(self.x+self.widthCar+TILEDIM/2, yNextPaths, filterPaths)


        local leftOK = lenLeftCarsObstacles==0 and lenLeftPaths==1
        local rightOK = lenRightCarsObstacles==0 and lenRightPaths==1

        local direction = nil
        if leftOK and rightOK then
            direction = (math.random(2) == 1) and "left" or "right"
        elseif leftOK then
            direction = "left"
        elseif rightOK then
            direction = "right"
        end

        if direction ~= nil then
            local pathToGo
            if direction == "left" then
                pathToGo = leftPaths[1]
            else
                pathToGo = rightPaths[1]
            end
            velX = (pathToGo.x-pathToGo.width/2) - (self.x + self.widthCar/2)
            self.targetX = pathToGo.x+pathToGo.width/2-self.widthCar/2
        else
            velY = velY/2
        end        
    elseif self.targetX ~= nil then -- No obstacle and no target already defined
        local carX = math.ceil(self.x-0.5)
        if self.targetX ~= carX then -- Car is not at targetX position
            velX = (self.targetX - carX)*2
        else --Car is at targetX position
            self.targetX = nil
        end
    end

    return velX, velY
end

function Car:commonUpdate(dt)
    self.currCarAnim:update(dt)
    self:manageStateCar()
    self:manageEffects(dt)
end

function Car:manageEffects(dt) --fire/explosion
    if self.onFire then --health == 2 --> smoke
        local fireSide
        if self.velocity.x > 3 then
            fireSide = "right"
        elseif self.velocity.x < -3 then
            fireSide = "left"
        else
            fireSide = "front"
        end

        if self.currFireAnim.name ~= fireSide then
            self.currFireAnim = {name=fireSide, anim=self.animations.fire[fireSide]}
        end
    end

    if self.isSmoking then
        self.smokeOffsetY = self.smokeOffsetY-dt*20
        self.animations.smoke.std:update(dt)
    elseif self.onFire then
        self.currFireAnim.anim:update(dt)
        if self.sfx.fire == nil --[[and self.sfx.fire:typeOf("Source")--]] then
            self.sfx.fire = soundManager:playSFX("fire", true, self.x, self.y)
        else
            self.sfx.fire:setPosition(self.x, self.y)
        end
    end
    if self.onFire and self.sfx.fire:isPlaying() and not gameState:isCurrentState("InGame") then
        self.sfx.fire:stop()
    elseif self.onFire and not self.sfx.fire:isPlaying() and gameState:isCurrentState("InGame") then
        self.sfx.fire:play()
    end

    if self.isExploding then
        self.explosionAnim:update(dt)
        self.opacity = self.opacity-dt/2

        if self.startExplosionSFX then
            if self.sfx.fire ~= nil then
                self.sfx.fire:stop()
            end
            soundManager:playSFX("explosion", false, self.x, self.y)
            self.startExplosionSFX = false
        end
    else
        self.startExplosionSFX = true
    end
end

function Car:manageStateCar() 
    self.isSmoking = self.health == 2
    self.onFire = self.health == 1
    self.isExploding = self.health <= 0 or self.isExploding
end

function Car:draw()
    if self.isExploding then
        love.graphics.setColor(0, 0, 0, self.opacity)
    end

    if self.direction == "left" and self.className ~= "Player" then
        self.currCarAnim:draw(self.spritesheet, self.x, self.y, math.pi, 1, 1, self.widthCar, self.heightCar)
    else
        self.currCarAnim:draw(self.spritesheet, self.x+self.widthCar, self.y+self.heightCar, nil, 1, 1, self.widthCar, self.heightCar)
    end
    if self.isSmoking then
        self.animations.smoke.std:draw(globalAssets.animations.smoke.spritesheet, self.x, self.y+self.motorPosY-self.smokeOffsetY)
    elseif self.onFire and self.currFireAnim.anim ~= nil then 
        self.currFireAnim.anim:draw(globalAssets.animations.fire.spritesheet, self.x, self.y+self.motorPosY)
    end

    if self.isExploding then
        love.graphics.setColor(1, 1, 1, self.opacity)
        self.explosionAnim:draw(globalAssets.animations.explosion.spritesheet, self.x-globalAssets.animations.explosion.spriteWidth/3, self.y-globalAssets.animations.explosion.spriteHeight+self.heightCar/2)
        love.graphics.setColor(1, 1, 1, 1)
    end
end