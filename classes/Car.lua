Car = class("Car")

function Car:init(textureName, widthCar, heightCar, speed, consumptionFactor)
    self.textureName = textureName
    self.spriteSheet = love.graphics.newImage("assets/textures/cars/"..self.textureName..".png")
    self.widthCar, self.heightCar = widthCar, heightCar
    self.x, self.y = 0, 0
    self.speed = speed
    self.fuel = 100
    self.consumptionFactor = consumptionFactor
    self.health = 10
    self.grid = anim8.newGrid(widthCar, heightCar, self.spriteSheet:getWidth(), self.spriteSheet:getHeight(), 0, 0, 0)
    self.collider = gameState.currentState.world:newBSGRectangleCollider(self.x, self.y, widthCar, heightCar, 5)
    self.collider:setFixedRotation(true)
    --self.collider:setCollisionClass(self.className)

    local animationSpeed = 1
    self.animations = {}
    self.animations.up = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.left = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.right = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.brake = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.anim = self.animations.up
end

function Car:update(args)
    self:move(args)
    self:manageCollisions()
end

function Car:manageCollisions()
    if self.className == "RoadUser" and self.collider:enter("Player") or self.className == "Player" and self.collider:enter("RoadUser") then
        self.health = self.health-1
        print(self.class, self.health)
    end
end

function Car:updatePosition(x, y)
    self.x, self.y = x, y
    self.collider:setPosition(x, y)
end

function Car:castToPlayer(x, y)
    local player = self:cast(Player)
    player:updatePosition(x, y)
    player.boostSpeedMult = 1.5

    player.currentSpeed = self.speed
    return player
end

function Car:castToRoadUser(x, y)
    local roadUser = RoadUser(self.textureName, self.widthCar, self.heightCar, self.speed, self.consumptionFactor)
    roadUser:updatePosition(x, y)
    return roadUser
end

function Car:addRandomRoadUsers(chunk)
    local maxNbCars = math.floor(chunk.sprites[1].height/6)
    local nbCars = math.random(1, maxNbCars)
    
    for i=1, nbCars do
        local rand = math.random(1, #chunk.paths)
        local randomPath = chunk.paths[rand]
        local carY = randomPath.y + randomPath.height/nbCars*i + math.random(-40, 40)
        local car = gameState.currentState.carModels.car2:castToRoadUser(randomPath.x+randomPath.width/2, carY)
        table.insert(gameState.currentState.roadUsers, car)
    end
end

function Car:addRandomRoadUser(chunk, posY)
    local rand = math.random(1, #chunk.paths)
    local randomPath = chunk.paths[rand]
    local car = gameState.currentState.carModels.car2:castToRoadUser(randomPath.x+randomPath.width/2, posY)
    table.insert(gameState.currentState.roadUsers, car)
end

function Car:deleteOldRoadUsers(posYStartingRemoving)
    for i, car in ipairs(gameState.currentState.roadUsers) do
        if car.y <= posYStartingRemoving then
            car.collider:destroy()
            table.remove(gameState.currentState.roadUsers, i)
        end
    end
end