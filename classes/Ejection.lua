Ejection = class("Ejection")

function Ejection:init(x, y)
    self.x, self.y = x, y
    self.minScale = 0.4
    self.scale = self.minScale
    self.maxScale = 1
    
    self.maxSpeed = 800

    self.velocity = {x=gameState.states["InGame"].player.velocity.x*10, y=gameState.states["InGame"].player.velocity.y*10}
    self.accX, self.accY = 0.08, 0.05 

    self.ejectTime = 0.25
    self.count = 0

    self.landOn = nil

    self.animations = {        
        backCenter = anim8.newAnimation(globalAssets.animations.capyman.grid(1, 1), 1),
        backLeft = anim8.newAnimation(globalAssets.animations.capyman.grid(2, 1), 1),
        backRight = anim8.newAnimation(globalAssets.animations.capyman.grid(3, 1), 1),
        frontCenter = anim8.newAnimation(globalAssets.animations.capyman.grid(1, 2), 1),
        frontLeft = anim8.newAnimation(globalAssets.animations.capyman.grid(3, 2), 1),
        frontRight = anim8.newAnimation(globalAssets.animations.capyman.grid(2, 2), 1),
        flatUp = anim8.newAnimation(globalAssets.animations.capyman.grid(2, 3), 1),
        flatDown = anim8.newAnimation(globalAssets.animations.capyman.grid(1, 3), 1)
    }
    self.currAnim = {name="backCenter", anim=self.animations.backCenter}
    self.widthSprite, self.heightSprite = globalAssets.animations.capyman.spriteWidth, globalAssets.animations.capyman.spriteHeight

    input:setCurrentJoyZ()
end

function Ejection:update(dt)
    local diffSpeed = gameState.states["InGame"].difficulty.speed
    if diffSpeed > 1 then
        diffSpeed = diffSpeed*1.25
    end
    
    self.count = self.count+dt*diffSpeed

    if self.count <= self.ejectTime then
        local velX, velY = self.velocity.x, self.velocity.y
        local accX, accY = self.accX*diffSpeed, self.accY*diffSpeed

        local ratio = math.min(self.count / (self.ejectTime/2), (self.ejectTime - self.count) / (self.ejectTime/2))
        ratio = math.max(0, math.min(1, ratio))
        
        self.scale = (self.maxScale - self.minScale) * ratio + self.minScale

        local speed = self.maxSpeed*math.min(0.55, ratio)        
        local targetVelY = (input.state.actions.up and speed) or (input.state.actions.down and -speed) or 0
        local targetVelX = (input.state.actions.right and speed) or (input.state.actions.left and -speed) or 0
        
        velY = accY * (targetVelY*input.state.accelerometer.tiltZ) + (1 - accY/2) * velY
        velX = accX * (targetVelX*input.state.accelerometer.tiltX) + (1 - accX/2) * velX
        
        self.velocity.x, self.velocity.y = velX, velY
        self.x, self.y = self.x + velX * dt, self.y - velY * dt

        local side
        if self.velocity.y >= 0 then --back
            if self.ejectTime-self.count <= dt then 
                side = "flatUp"
            elseif self.velocity.x < -50 then
                side = "backLeft"
            elseif self.velocity.x > 50 then
                side = "backRight"
            else
                side = "backCenter"
            end
        else --front
            if self.ejectTime-self.count <= dt then 
                side = "flatDown"
            elseif self.velocity.x < -50 then
                side = "frontLeft"
            elseif self.velocity.x > 50 then
                side = "frontRight"
            else
                side = "frontCenter"
            end
        end

        if self.currAnim.name ~= side then
            self.currAnim = {name=side, anim=self.animations[side]}
        end

        if self.currAnim.anim ~= nil then
            self.currAnim.anim:update(dt)
        end

    else 
        self.landOn = self:checkCarUnder()
    end

    love.audio.setPosition(self.x, self.y, 0)
end

function Ejection:checkCarUnder()
    local function checkIntersect(rectX, rectY, rectW, rectH, circleX, circleY, circleR)
        deltaX = circleX - math.max(rectX, math.min(circleX, rectX + rectW));
        deltaY = circleY - math.max(rectY, math.min(circleY, rectY + rectH));
        return (deltaX * deltaX + deltaY * deltaY) < (circleR * circleR);
    end

    for i, car in ipairs(gameState.states["InGame"].cars) do
        if checkIntersect(car.x, car.y, car.widthCar, car.heightCar, self.x, self.y, math.max(self.widthSprite, self.heightSprite)/2*self.scale) then
            return i
        end
    end
    return 0
end


function Ejection:draw()
    local offsetX, offsetY = self.widthSprite*self.scale/2, self.heightSprite*self.scale/2

    --love.graphics.circle("line", self.x, self.y, math.max(offsetX, offsetY))
    self.currAnim.anim:draw(globalAssets.animations.capyman.spritesheet, self.x-offsetX, self.y-offsetY, 0, self.scale)
end