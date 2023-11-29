RoadUser = Car:extend("RoadUser")

function RoadUser:init(textureNameOrModel, widthCar, heightCar, speed, consumptionFactor, direction)
    RoadUser.super.init(self, textureNameOrModel, widthCar, heightCar, speed, consumptionFactor)

    self.direction = direction
end

function RoadUser:move(args)
    local vx, vy = 0, 0
    if self.direction == "right" then
        vy = self.speed/2
    else
        vy = -(self.speed/2)
    end

    self.collider:setLinearVelocity(vx, vy)

    self.x, self.y = math.floor(self.collider:getX()-self.widthCar/2), math.floor(self.collider:getY()-self.heightCar/2)

    self.anim:update(args.dt)
end