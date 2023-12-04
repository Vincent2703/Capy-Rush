Car = class("Car")

function Car:init(textureName, widthCar, heightCar, maxSpeed, consumptionFactor)
    self.textureName = textureName
    self.spriteSheet = love.graphics.newImage("assets/textures/cars/"..self.textureName..".png")
    self.widthCar, self.heightCar = widthCar, heightCar
    self.x, self.y = 0, 0
    self.maxSpeed = maxSpeed
    self.velocity = {x=0, y=0}
    self.accX = 0.04
    self.accY = 0.02
    self.fuel = 100
    self.consumptionFactor = consumptionFactor
    self.health = 10
    self.lastCollision = 0
    self.delayDamage = 2
    self.grid = anim8.newGrid(widthCar, heightCar, self.spriteSheet:getWidth(), self.spriteSheet:getHeight(), 0, 0, 0)

    local animationSpeed = 1
    self.animations = {}
    self.animations.up = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.left = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.right = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.brake = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.anim = self.animations.up
end

function Car:manageCollisions(velX, velY, dt) 
    self.lastCollision = self.lastCollision+dt
    local goalX, goalY = self.x + velX*dt, self.y + velY*dt
    local actualX, actualY, cols, len = gameState.states["InGame"].world:check(self, goalX, goalY, function() return "bounce" end)
    local health = self.health

    if len > 0 then
        if self.lastCollision >= self.delayDamage and velY > 0 then
            self.lastCollision = 0
            health = health-1
        end
        local other = cols[1].other
        local normal = cols[1].normal
        if other.className == "RoadUser" then
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

    return velX, velY, goalX, goalY, health
end

function Car:updatePosition(x, y)
    self.x, self.y = x-self.widthCar/2, y-self.heightCar/2
    gameState.states["InGame"].world:update(self, x, y)
end

function Car:castToPlayer(x, y)
    local player = self:cast(Player)
    player.boostSpeedMult = 1.5

    player.currentSpeed = self.maxSpeed
    gameState.states["InGame"].world:add(player, player.x, player.y, player.widthCar, player.heightCar)
    player:updatePosition(x, y)
    return player
end

function Car:castToRoadUser(x, y, direction)
    local roadUser = RoadUser(self.textureName, self.widthCar, self.heightCar, self.maxSpeed, self.consumptionFactor, direction)
    gameState.states["InGame"].world:add(roadUser, roadUser.x, roadUser.y, roadUser.widthCar, roadUser.heightCar)
    roadUser:updatePosition(x, y)
    return roadUser
end

function Car:addRandomRoadUser(chunk, posY)
    local rand = math.random(1, #chunk.paths)
    local randomPath = chunk.paths[rand]
    local car = gameState.states["InGame"].carModels.car2:castToRoadUser(randomPath.x+randomPath.width/2, posY, randomPath.direction)
    table.insert(gameState.states["InGame"].roadUsers, car)
end

function Car:deleteOldRoadUsers(posYStartingRemoving)
    local roadUsers = gameState.states["InGame"].roadUsers
    for i, car in ipairs(roadUsers) do
        if car.y <= posYStartingRemoving then
            gameState.states["InGame"].world:remove(car)
            table.remove(roadUsers, i)
        end
    end
end