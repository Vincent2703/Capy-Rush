RoadUser = Car:extend("RoadUser")

function RoadUser:init(textureNameOrModel, widthCar, heightCar, speed, consumptionFactor)
    RoadUser.super.init(self, textureNameOrModel, widthCar, heightCar, speed, consumptionFactor)
    
    self.startMoving = false
end

function RoadUser:move(args)
    local vx, vy = 0, 0

    --if self.startMoving or self.y <= args.yStartMoving then
        vy = self.speed/2
        self.startMoving = true
    --end

    self.collider:setLinearVelocity(vx, vy)

    self.x, self.y = math.floor(self.collider:getX()-self.widthCar/2), math.floor(self.collider:getY()-self.heightCar/2)

    self.anim:update(args.dt)
end