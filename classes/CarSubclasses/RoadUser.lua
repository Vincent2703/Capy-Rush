RoadUser = Car:extend("RoadUser")

function RoadUser:init(x, y, textureName, speed, consumptionFactor)
    RoadUser.super.init(self, x, y, textureName, speed, consumptionFactor)
end

function RoadUser:move(dt)
    local vx, vy = 0, self.speed

    self.collider:setLinearVelocity(vx, vy)

    self.x, self.y = math.floor(self.collider:getX()-self.widthCar/2), math.floor(self.collider:getY()-self.heightCar/2)

    self.anim:update(dt)
end