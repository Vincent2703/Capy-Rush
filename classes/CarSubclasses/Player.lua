Player = Car:extend("Player")

function Player:init(textureName, widthCar, heightCar, maxSpeed, consumptionFactor)
    Player.super.init(self, textureName, widthCar, heightCar, maxSpeed, consumptionFactor)
end

function Player:update(dt)
    local accX = self.accX
    local accY = self.accY

    local velX, velY = self.velocity.x, self.velocity.y

    --self.fuel = math.max(0, tonumber(string.format("%.2f", self.fuel - self.consumptionFactor)))

    -- Update velocity based on input
    local targetVelX = 0
    if input.state.actions.right or (input.state.actions.click and input.state.mouse.relX > widthRes/2) then
        targetVelX = self.maxSpeed
        self.anim = self.animations.right
    elseif input.state.actions.left or (input.state.actions.click and input.state.mouse.relX < widthRes/2) then
        targetVelX = -self.maxSpeed
        self.anim = self.animations.left
    end

    -- Smoothly adjust velocity towards the target
    velX = accX * targetVelX + (1 - accX) * velX

    -- Decelerate when neither left nor right is pressed
    if not input.state.actions.right and not input.state.actions.left then
        velX = velX + velX * accX*dt
    end

    -- Update y-velocity
    velY = accY * self.maxSpeed + (1 - accY) * velY

    if self.fuel <= 0 then
        velY = math.floor(self.velocity.y*0.995)
        velX = math.floor(velY/self.maxSpeed*velX)
    end

    -- Move player using the velocity

    local velX, velY, goalX, goalY, health = self:manageCollisions(velX, velY, dt)
    self.health = health

    local actualX, actualY, cols, len = gameState.states["InGame"].world:move(self, goalX, goalY)
    
    self.x, self.y = actualX, actualY

    self.velocity.x = velX
    self.velocity.y = velY

    -- Update animation
    self.anim:update(dt)
end
