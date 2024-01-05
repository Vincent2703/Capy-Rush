Ejection = class("Ejection")

function Ejection:init(x, y)
    self.x, self.y = x, y
    self.minRadius = 5
    self.radius = self.minRadius
    self.maxRadius = 20
    
    self.maxSpeed = 900

    self.velocity = {x=gameState.states["InGame"].player.velocity.x*10, y=gameState.states["InGame"].player.velocity.y*10}
    self.accX, self.accY = 0.08, 0.07

    self.ejectTime = 0.25
    self.count = 0

    self.landOn = nil

    input:setCurrentJoyZ()
end

function Ejection:update(dt)
    self.count = self.count+dt

    if self.count <= self.ejectTime then
        local velX, velY = self.velocity.x, self.velocity.y
        local accX, accY = self.accX, self.accY

        local ratio = 0
        if self.count <= self.ejectTime/2 then
            ratio = self.count/(self.ejectTime/2)
        else
            ratio = (-self.count+self.ejectTime)/(0.5*self.ejectTime)
        end
        self.radius = (self.maxRadius - self.minRadius) * ratio + self.minRadius

        local speed = self.maxSpeed*ratio        
        local targetVelY = (input.state.actions.up and speed) or (input.state.actions.down and -speed) or 0
        local targetVelX = (input.state.actions.right and speed) or (input.state.actions.left and -speed) or 0
        
        velY = accY * (targetVelY*input.state.joystick.inclinZRatio) + (1 - accY/2) * velY
        velX = accX * (targetVelX*input.state.joystick.inclinXRatio) + (1 - accX/2) * velX
        
        self.velocity.x, self.velocity.y = velX, velY
        self.x, self.y = self.x + velX * dt, self.y + velY * dt
    else 
        self.landOn = self:checkCarUnder()
    end
end

function Ejection:checkCarUnder()
    local function checkIntersect(rectX, rectY, rectW, rectH, circleX, circleY, circleR)
        deltaX = circleX - math.max(rectX, math.min(circleX, rectX + rectW));
        deltaY = circleY - math.max(rectY, math.min(circleY, rectY + rectH));
        return (deltaX * deltaX + deltaY * deltaY) < (circleR * circleR);
    end

    for i, car in ipairs(gameState.states["InGame"].cars) do
        if checkIntersect(car.x, car.y, car.widthCar, car.heightCar, self.x, self.y, self.radius) then
            return i
        end
    end
    return 0
end


function Ejection:render()
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(255, 255, 255)
end