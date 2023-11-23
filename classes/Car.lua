Car = class("Car")

function Car:init(textureName, widthCar, heightCar, speed, consumptionFactor)
    self.textureName = textureName
    self.spriteSheet = love.graphics.newImage("assets/textures/cars/"..self.textureName..".png")
    self.widthCar, self.heightCar = widthCar, heightCar
    self.x, self.y = 0, 0
    self.speed = speed
    self.fuel = 100
    self.consumptionFactor = consumptionFactor
    self.health = 5
    self.grid = anim8.newGrid(widthCar, heightCar, self.spriteSheet:getWidth(), self.spriteSheet:getHeight(), 0, 0, 0)
    self.collider = world:newBSGRectangleCollider(self.x, self.y, widthCar, heightCar, 5)
    self.collider:setFixedRotation(true)

    local animationSpeed = 1
    self.animations = {}
    self.animations.up = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.left = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.right = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.brake = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.anim = self.animations.up
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