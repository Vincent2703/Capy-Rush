Car = class("Car")

function Car:init(spritesData, maxSpeed, maxHealth, consumptionFactor, isPolice)
    self.spritesData = spritesData
    self.widthCar, self.heightCar = self.spritesData.widthSprite, self.spritesData.heightSprite

    self.spritesheet = self.spritesData.spritesheet
    self.animations = {}
    self.animations.normal = anim8.newAnimation(self.spritesData.grid("1-1", 1), 1)
    self.animations.ejection = anim8.newAnimation(self.spritesData.grid("1-1", 2), 1)
    self.currentAnim = self.animations.normal

    self.x, self.y = 0, 0
    self.maxSpeed = maxSpeed
    self.velocity = {x=0, y=0}
    self.accX = 0.18
    self.accY = 0.01
    self.fuel = 100
    self.consumptionFactor = consumptionFactor
    self.maxHealth = maxHealth
    self.health = maxHealth

    self.lastCollision = 0
    self.delayDamage = 2

    self.isPolice = isPolice or false
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
            if self.lastCollision >= self.delayDamage and velY >= 0.15 * self.maxSpeed then
                -- Reduce health of both the player and the other car
                other.health = other.health-1
                self.health = self.health-1
                -- Reset the collision timer
                self.lastCollision = 0
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
        -- Check if the colliding item is an obstacle
        elseif other.isObstacle then
            -- Adjust velocities based on the collision
            if normal.x ~= 0 then
                velX, velY = 0, velY / 2
            elseif normal.y == 1 then
                velX, velY = velX / 2, 0
            end

            -- Check if the current car is the player, enough time has passed since the last collision, and the velocity is high enough
            if self.className == "Player" and self.lastCollision >= self.delayDamage and velY >= 0.15 * self.maxSpeed then
                -- Reduce the player's health and reset the collision timer
                self.health = self.health-1
                self.lastCollision = 0
            end
        end
    end

    return velX, velY, goalX, goalY, playerCollidesCar
end



function Car:updatePosition(x, y)
    self.x, self.y = x, y
    gameState.states["InGame"].world:update(self, x, y)
end

function Car:castToPlayer(x, y)
    local player = self:cast(Player)

    player.currentSpeed = self.maxSpeed
    gameState.states["InGame"].world:add(player, player.x, player.y, player.widthCar, player.heightCar)
    player:updatePosition(x, y)
    return player
end

function Car:castToRoadUser(x, y, direction)
    local roadUser = RoadUser(self.spritesData, self.maxSpeed, self.health, self.consumptionFactor, direction)
    roadUser.direction = direction
    gameState.states["InGame"].world:add(roadUser, roadUser.x, roadUser.y, roadUser.widthCar, roadUser.heightCar)
    roadUser:updatePosition(x, y)
    return roadUser
end

function Car:castToPolice(x, y, direction)
    local police = Police(self.spritesData, self.maxSpeed, self.health, self.consumptionFactor, direction)
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

function Car:switchCar()
    local player = self:cast(Player)
    local inGame = gameState.states["InGame"] 
    inGame.UI["fuelGauge"].player = player
    local cars = inGame.cars

    for i, v in ipairs(cars) do
        if v == self then
            table.remove(cars, i)
            break
        end
    end
    return player
end


function Car:filterColliders(item, other)
    if other.isObstacle then 
        return "slide" 
    elseif other.className == "RoadUser" or other.className == "Player" or other.className == "Police" then --:subclassOf() does not work
        return "bounce"
    else
        return nil
    end
end

function Car:manageTrajectory(velX, velY)
    local velX = velX or 0
    local velY = velY or self.currMaxSpeed

    local inGame = gameState.states["InGame"]
    local world = inGame.world
    
    local filterCars = function(item) --Detect cars, minus the player
        return (item.className == "RoadUser" or item.className == "Police") and self ~= item
    end

    local filterCarsObstacles = function(item) --Detect cars (including Player) and obstacles
        return (item.isObstacle or item.className == "RoadUser" or item.className == "Police" or item.className == "Player") and self ~= item --Instanceof Car
    end

    local filterPaths = function(item) --Detect paths
        return item.isPath
    end

    local queryTopPathsY
    local queryTopCarsY
    if self.direction == "right" then
        queryTopPathsY = self.y-self.heightCar*3
        queryTopCarsY = self.y-self.heightCar*2
    else
        queryTopPathsY = self.y+self.heightCar*4
        queryTopCarsY = self.y+self.heightCar*3
    end
    local _, lenTopPaths = world:queryPoint(self.x+self.widthCar/2, queryTopPathsY, filterPaths)
    local cars, lenTopCars = world:queryRect(self.x, queryTopCarsY, self.widthCar, self.heightCar*2, filterCars)

    if (lenTopPaths == 0 or lenTopCars > 0) and self.targetX == nil then -- No path or car(s) and no target already defined

        local _, lenLeftCarsObstacles = world:queryRect(self.x-self.widthCar/2-TILEDIM/2, self.y, self.widthCar, self.heightCar*3, filterCarsObstacles)
        local _, lenRightCarsObstacles = world:queryRect(self.x+self.widthCar/2+TILEDIM/2, self.y, self.widthCar, self.heightCar*3, filterCarsObstacles)

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
    --[[elseif lenTopPaths == 1 and lenTopCars == 0 and self.targetX == nil and self.correctTrajectory then -- Path, no car and no target
        --if self.lastCollision > 1 then
            local currentPath, lenPath = world:queryPoint(self.x, self.y, filterPaths)
            if lenPath == 1 then
                local targetX = currentPath[1].x+currentPath[1].width/2-self.widthCar/2 
                if targetX ~= self.x then
                    self.targetX = targetX
                    velX = targetX - self.x
                    self.correctTrajectory = false
                end
            end
        --end--]]
    end

    return velX, velY
end