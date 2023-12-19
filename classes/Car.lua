Car = class("Car")

function Car:init(textureName, widthCar, heightCar, maxSpeed, maxHealth, consumptionFactor, isPolice)
    self.textureName = textureName
    self.spriteSheet = love.graphics.newImage("assets/textures/cars/"..self.textureName..".png")
    self.widthCar, self.heightCar = widthCar, heightCar
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
    self.grid = anim8.newGrid(widthCar, heightCar, self.spriteSheet:getWidth(), self.spriteSheet:getHeight(), 0, 0, 0)

    self.isPolice = isPolice or false

    --self.detectionBoxes = 

    local animationSpeed = 1
    self.animations = {}
    self.animations.up = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.left = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.right = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.brake = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.anim = self.animations.up
end

function Car:preMove(velX, velY, dt) 
    self.lastCollision = self.lastCollision+dt

    local goalX, goalY = tonumber(string.format("%.2f", self.x + velX*dt)), tonumber(string.format("%.2f", self.y + velY*dt)) 

    local filter = function(item, other) return self:filterColliders(item, other) end

    local actualX, actualY, cols, len = gameState.states["InGame"].world:check(self, goalX, goalY, filter)

    local health = self.health

    local playerCollidesCar = false

    if len > 0 then
        if self.lastCollision >= self.delayDamage and velY >= 0.15*self.maxSpeed then

            self.lastCollision = 0
            health = health-1
        end
        local other = cols[1].other
        local normal = cols[1].normal
        local item = cols[1].item
        if other.className == "RoadUser" or other.className == "Police" then
            if item.className == "Player" then
                playerCollidesCar = true
            end
            if normal.x ~= 0 then
                velX = velX/2
                velY = velY*0.75

                other.velocity.x = other.velocity.x + self.velocity.x/2 
                other.velocity.y = math.max(velY, other.velocity.y/2)
            elseif normal.y == -1 then
                velX = velX/2
                velY = velY/2

                other.velocity.y = other.velocity.y + self.velocity.y/2
            end
        elseif other.isObstacle then
            if normal.x ~= 0 then
                velX = 0
                velY = velY/2
            elseif normal.y == -1 then
                velX = velX/2
                velY = 0
            end 
        end
    end

    return velX, velY, goalX, goalY, health, playerCollidesCar
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
    local roadUser = RoadUser(self.textureName, self.widthCar, self.heightCar, self.maxSpeed, self.health, self.consumptionFactor, direction)
    roadUser.direction = direction
    gameState.states["InGame"].world:add(roadUser, roadUser.x, roadUser.y, roadUser.widthCar, roadUser.heightCar)
    roadUser:updatePosition(x, y)
    return roadUser
end

function Car:castToPolice(x, y, direction)
    local police = Police(self.textureName, self.widthCar, self.heightCar, self.maxSpeed, self.health, self.consumptionFactor, direction)
    --local police = self:cast(Police)
    --police.direction = direction
    gameState.states["InGame"].world:add(police, police.x, police.y, police.widthCar, police.heightCar)
    police:updatePosition(x, y)
    return police
end

function Car:addRandomCar(chunk, posY)
    local rand = math.random(1, #chunk.paths)
    local randomPath = chunk.paths[rand]

    local randomValue = math.random()
    local cumulativeRatio = 0

    local randCar = nil
    for _, model in pairs(gameState.states["InGame"].carModels) do
        cumulativeRatio = cumulativeRatio + model.ratio
        if randomValue <= cumulativeRatio then
            randCar = model.car
            break
        end
    end

    local car
    if not randCar.isPolice then
        car = randCar:castToRoadUser(randomPath.x+randomPath.width/2-randCar.widthCar/2, posY, randomPath.direction)
    else
        car = randCar:castToPolice(randomPath.x+randomPath.width/2-randCar.widthCar/2, posY, randomPath.direction)
    end
    table.insert(gameState.states["InGame"].cars, car)
   
end

function Car:deleteOldCars(posYStartingRemoving)
    local cars = gameState.states["InGame"].cars
    
    for _, car in ipairs(cars) do
        if car.y <= posYStartingRemoving then
            car:destroy()
        end
    end
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

function Car:avoidObstacles(goalX)
    local goalX = goalX or 0

    local inGame = gameState.states["InGame"]
    local world = inGame.world
    
    local filterObstacles = function(item) 
        return item.isObstacle or item.className == "RoadUser" or item.className == "Police"
    end

    local filterPaths = function(item)
        return item.isPath
    end

    local itemsTop, lenTop = world:queryRect(self.x, self.y+self.heightCar*3, self.widthCar, self.heightCar, filterObstacles)
    if lenTop > 0 then
        local _, lenLeftObstacles = world:queryRect(self.x-self.widthCar*1.5, self.y, self.widthCar, self.heightCar, filterObstacles)
        local _, lenRightObstacles = world:queryRect(self.x+self.widthCar*1.5, self.y, self.widthCar, self.heightCar, filterObstacles)

        local itemsLeftPaths, lenLeftPaths = world:queryPoint(self.x-self.widthCar/2, self.y, filterPaths) --Pourquoi ça marche quand on fait /2 ?
        local itemsRightPaths, lenRightPaths = world:queryPoint(self.x+self.widthCar*2, self.y, filterPaths)

        local leftOK = lenLeftObstacles==0 and lenLeftPaths==1
        local rightOK = lenRightObstacles==0 and lenRightPaths==1

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
                pathToGo = itemsLeftPaths[1] -- Pourquoi ça prend celui le plus à gauche ?? (proche de 0)
                print(pathToGo.x)
            else
                pathToGo = itemsRightPaths[1]
            end
            goalX = (pathToGo.x-pathToGo.width/2) - (self.x + self.widthCar/2)
            self.targetX = pathToGo.x+pathToGo.width/2-self.widthCar/2
        end        
    else
        if self.targetX ~= nil and self.targetX ~= self.x then
            goalX = self.targetX - self.x
           -- print(goalX)
        else
            self.targetX = nil
        end
        --goalX = self.targetX
        --[[if self.lastCollision > 0.5 then
            local currentPath, lenPath = world:queryPoint(self.x, self.y, filterPaths)
            if lenPath == 1 then
                local targetX = currentPath[1].x+currentPath[1].width/2-self.widthCar/2 
                if targetX ~= self.x then
                    goalX = targetX - self.x
                end
            end
        end--]]
    end

    return goalX
end