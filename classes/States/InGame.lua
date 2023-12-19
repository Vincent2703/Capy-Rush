InGame = class("InGame")

function InGame:init()
    self.world = self:createWorld()

    self.zoom = 1.5
    
    self.difficulties = {
        {id = 1, rate = 0.5, nbMaxCars = 1},
        {id = 2, rate = 0.5, nbMaxCars = 2},
        {id = 3, rate = 0.6, nbMaxCars = 2},
        {id = 4, rate = 0.7, nbMaxCars = 2},
        {id = 5, rate = 0.7, nbMaxCars = 3},
        {id = 6, rate = 0.8, nbMaxCars = 3},
        {id = 7, rate = 0.8, nbMaxCars = 4},
        {id = 8, rate = 0.9, nbMaxCars = 4},
    }

    self.carModels = self:createCarsModels()
end

function InGame:start() -- On restart
    self.lvl = self:createMap()

    local modelCar = self.carModels.car1.car
    self.player = modelCar:castToPlayer(self.lvl.mapChunks[1].paths[1].x+self.lvl.tileWidth/2-modelCar.widthCar/2, 50)
    self.player.velocity.y, self.player.velocity.x = 0, 0
    self.player.fuel = 100
    self.player.health = self.player.maxHealth

    self.inCar = true

    self.UI = self:createUI()

    self.difficulty = self.difficulties[4]
    --self.policeCars = 1

    self.stats = Stats()

    self.distanceCount = 0
    self.prevYPos = 0

    self.cars = {}

    self.landingStatus = false
    self.eject = false
    self.ejection = nil
end

function InGame:update(dt)
    if gameState:isCurrentState("InGame") then
        if (input.state.actions.newPress.eject 
        or (input.state.actions.newPress.click and input.state.mouse.absY <= 0.9*heightWindow and input.state.mouse.absY >= 0.1*heightWindow)) 
        and not self.eject then
            self:manageEjection(true)
        elseif (input.state.actions.newPress.eject 
        or (input.state.actions.newPress.click and input.state.mouse.absY <= 0.9*heightWindow and input.state.mouse.absY >= 0.1*heightWindow)) 
        and self.eject and not self.landingStatus then
            self:manageEjection(false)
        elseif input.state.actions.newPress.pause then
            gameState:setState("Pause", true)
        end

        if self.eject then
            if not self.landingStatus then
                dt = dt/10
            else
                dt = dt/3
            end
            self.ejection:update(dt)

            if self.ejection.landOn ~= nil then
                self.eject = false
                if self.ejection.landOn == 0 then
                    gameState:setState("GameOver", true)
                else 
                    local car = self.cars[self.ejection.landOn]
                    self.UI["fuelGauge"].visible = true
                    if car.direction == "left" then
                        self.stats.multipliers.glob = 2
                    else
                        self.stats.multipliers.glob = 1
                    end
                    self.player = car:switchCar()
                    self.inCar = true
                    self.stats:addPoints("ejections")
                end
            end
        else
            if self.player.health <= 0 then
                gameState:setState("GameOver", true)
            end

            if self.stats.scores.current >= self.difficulty.id*100 and self.difficulty.id < #self.difficulties then
                self:setDifficulty(self.difficulty.id+1)
            end
            if self.player.currPathDir == "left" and self.stats.multipliers.glob == 1 then
                self.stats.multipliers.glob = 2
            elseif self.player.currPathDir == "right" and self.stats.multipliers.glob == 2 then
                self.stats.multipliers.glob = 1
            end
        end

        for key, ui in pairs(self.UI) do 
            if ui.visible then
                ui:update()
            end
        end

        self:updateAllCars(dt)

        if self.inCar then
            if self.player.fuel <= 0 and self.player.velocity.y == 0 then
                gameState:setState("GameOver", true)
            end

            if self.player.y >= self.lvl.map.height*self.lvl.tileHeight - heightRes*1.5 then
                self.lvl:manageChunks()
                Car:deleteOldCars(self.player.y-heightRes)
            end

            local dist = self.player.y-self.prevYPos
            self.stats:addPoints("distance", dist)
            self.distanceCount = self.distanceCount + dist
            self.prevYPos = self.player.y
            if self.distanceCount >= 500 then
                self.distanceCount = 0
                local rand = math.random()
                if rand <= self.difficulty.rate then
                    local chunk = self.lvl.mapChunks[self.lvl:getNbChunkAtPos(self.player.y)]
                    local nbCars = math.random(1, self.difficulty.nbMaxCars)
                    for i=1, nbCars do
                        Car:addRandomCar(chunk, self.player.y+heightRes+math.random(0, heightRes))
                    end
                end
            end
        end
    end
    
end

function InGame:render()
    -- Set the canvas as the render target
    love.graphics.setCanvas(preRenderCanvas)

    love.graphics.translate(self:manageCamera())
    love.graphics.scale(self.zoom, self.zoom)

    -- Draw the map layers
    for _, layer in ipairs(self.lvl.map.layers) do
        if layer.type == "tilelayer" then
            self.lvl.map:drawLayer(layer)
        end
    end

    -- Draw the player and road users
    self:drawAllCars()

    --[[local items, len = self.world:getItems()
    for i = 1, len do
    local x, y, w, h = self.world:getRect(items[i])
    love.graphics.rectangle("line", x, y, w, h)
    end--]]

    if self.eject then
        self.ejection:render()
    end

    -- Reset transformations
    love.graphics.origin()

    -- Flip horizontally and scale the canvas
    love.graphics.translate(offsetXCanvas, heightWindow)
    love.graphics.scale(ratioScale, -ratioScale)

    -- Set the default canvas
    love.graphics.setCanvas()

    -- Draw the preRenderCanvas to the screen
    love.graphics.draw(preRenderCanvas)

    -- Reset transformations
    love.graphics.origin()

    love.graphics.translate(offsetXCanvas, camYOffset)
    love.graphics.scale(ratioScale, ratioScale)

    -- Draw UI elements
    for _, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end

    -- Temp life count and score
    if self.inCar then
        love.graphics.print(self.player.health, 100, 10)
    end

    love.graphics.print(math.abs(math.ceil(self.stats.scores.current-0.5)), 250, 10)

    love.graphics.print('x: '..input.state.joystick.x..' \n('..math.abs(math.ceil(input.state.joystick.inclinXRatio*100-0.5))..'%)\n\nz: '..input.state.joystick.z..'\n('..math.abs(math.ceil(input.state.joystick.inclinZRatio*100-0.5))..'%)', 5, 60)

    love.graphics.print("diff: "..self.difficulty.id, widthRes-100, 10)
end


function InGame:setDifficulty(indexDifficulty)
    self.difficulty = self.difficulties[indexDifficulty]
end

function InGame:createWorld()
    local world = bump.newWorld()

    return world
end

function InGame:createMap()
    local lvl = Map(48, 48, 
    "assets/textures/roads/tileset.png",
    {
        chunk1 = {path="assets/maps/chunk1.lua", ratio=0},
        chunk2 = {path="assets/maps/chunk2.lua", ratio=0.5},
        chunk3 = {path="assets/maps/chunk3.lua", ratio=0.5}
    }, 5)

    return lvl
end

function InGame:createCarsModels()
    local carModels = {
        car1 = {car = Car("car1", 32, 35, 400, 5, 4), ratio=0.5},
        car2 = {car = Car("car2", 32, 35, 450, 4, 3.2), ratio=0.4},
        police1 = {car = Car("police1", 32, 35, 450, 6, 3.2, true), ratio=0.1}
    }

    return carModels
end

function InGame:createUI()
    local UIElements = {}

    UIElements["fuelGauge"] = FuelGauge(
        10, 
        heightRes-30, 
        widthRes-20, 
        20, 
        true
    )

    return UIElements
end

function InGame:updateAllCars(dt)
    if self.inCar then
        self.player:update(dt)
    end

    for _, car in ipairs(self.cars) do
        car:update(dt)
        if car.health <= 0 then
            car:destroy()
        end
    end
end

function InGame:drawAllCars()
    if self.inCar then
        local player = self.player
        player.anim:draw(player.spriteSheet, player.x, player.y, math.pi, 1, 1, player.widthCar, player.heightCar)
    end
    for _, car in ipairs(self.cars) do
        if car.direction == "left" then
            car.anim:draw(car.spriteSheet, car.x, car.y+car.heightCar, math.pi, 1, -1, car.widthCar, car.heightCar)
        else
            car.anim:draw(car.spriteSheet, car.x, car.y, math.pi, 1, 1, car.widthCar, car.heightCar)
            love.graphics.rectangle("fill", car.x-car.widthCar, car.y, 5, 5)
        end
    end
end

function InGame:manageCamera()
    local player, ejection = self.player, self.ejection
    local trX, trY = 0, 0
    if self.inCar then
        trX = math.min(0, math.max(-player.x * self.zoom + widthRes / 2, -widthRes / 2))
        trY = math.min(0, ((-player.y + player.heightCar * 3) * self.zoom + camYOffset))
    elseif self.eject then
        trX = math.min(0, math.max(-ejection.x * self.zoom + widthRes / 2, -widthRes / 2))
        trY = math.min(0, ((-ejection.y + 96 + ejection.maxRadius) * self.zoom + camYOffset))
    end
    return trX, trY
end

function InGame:manageEjection(ejection)
    if ejection then
        self.landingStatus = false
        self.eject = true
        self.inCar = false
        self.UI["fuelGauge"]:toggleVisibility()
        self.ejection = Ejection(self.player.x+self.player.widthCar/2, self.player.y+self.player.heightCar/2)
        self.player:destroy()
    else
        self.landingStatus = true
        self.ejection.velocity.x, self.ejection.velocity.y = self.ejection.velocity.x/2, self.ejection.velocity.y/2
        self.ejection.maxSpeed = self.ejection.maxSpeed/2
    end
end