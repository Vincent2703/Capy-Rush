Car = class("Car")

function Car:init(x, y, textureName, speed, consumptionFactor)
    self.textureName = textureName
    self.spriteSheet = love.graphics.newImage("assets/textures/cars/"..self.textureName..".png")
    self.widthCar, self.heightCar = 32, 35
    self.x, self.y = x-self.widthCar/2, y-self.heightCar/2
    self.speed = speed
    self.consumptionFactor = consumptionFactor
    self.health = 5

    self.grid = anim8.newGrid(self.widthCar, self.heightCar, self.spriteSheet:getWidth(), self.spriteSheet:getHeight(), 0, 0, 0)
    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.widthCar, self.heightCar, 5)
    self.collider:setFixedRotation(true)

    local animationSpeed = 1
    self.animations = {}
    self.animations.up = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.left = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.right = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.animations.brake = anim8.newAnimation(self.grid("1-1", 1), animationSpeed)
    self.anim = self.animations.up
end