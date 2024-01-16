InGame = class("InGame")

function InGame:init()
    self.world = self:createWorld()

    self.zoom = 2.5
    
    self.difficulties = {
        {id = 1, rate = 0.6, nbMaxCars = 1},
        {id = 2, rate = 0.6, nbMaxCars = 2},
        {id = 3, rate = 0.7, nbMaxCars = 2},
        {id = 4, rate = 0.7, nbMaxCars = 3},
        {id = 5, rate = 0.8, nbMaxCars = 3},
        {id = 6, rate = 0.8, nbMaxCars = 4},
        {id = 7, rate = 0.9, nbMaxCars = 4},
        {id = 8, rate = 0.9, nbMaxCars = 5},
    }

    self.carModels = self:createCarsModels()
end

function InGame:start() -- On restart
    self.lvl = self:createMap()

    local modelCar = self.carModels.car1.car
    self.player = modelCar:castToPlayer(self.lvl.mapChunks[1].paths[1].x+TILEDIM/2-modelCar.widthCar/2, -50)
    self.player.velocity.y, self.player.velocity.x = 0, 0
    self.player.fuel = 100
    self.player.health = self.player.maxHealth

    self.inCar = true

    self.UI = self:createUI()

    self.difficulty = self.difficulties[3]

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
        or (input.state.actions.newPress.click and input.state.mouse.y <= 0.9*heightWindow and input.state.mouse.y >= 0.1*heightWindow)) 
        and not self.eject then
            self:manageEjection(true)
        elseif (input.state.actions.newPress.eject 
        or (input.state.actions.newPress.click and input.state.mouse.y <= 0.9*heightWindow and input.state.mouse.y >= 0.1*heightWindow)) 
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

            if self.stats.scores.current >= self.difficulty.id*50 and self.difficulty.id < #self.difficulties then
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

            if self.player.y <= -self.lvl.map.height*self.lvl.tileHeight + heightRes*1.5 then
                self.lvl:manageChunks()
                InGame:deleteOldCars(self.player.y-heightRes)
            end

            local dist = self.prevYPos-self.player.y
            self.stats:addPoints("distance", dist)
            self.distanceCount = self.distanceCount + dist
            self.prevYPos = self.player.y
            if self.distanceCount >= 500 then
                self.distanceCount = 0
                local rand = math.random()
                if rand <= self.difficulty.rate then
                    local nbCars = math.random(1, self.difficulty.nbMaxCars)

                    for i=1, nbCars do
                        self:addCarRandomly()
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
    --love.graphics.translate(-self.player.x, -self.player.y)
    love.graphics.scale(self.zoom, self.zoom)

    -- Draw the map layers
    for _, layer in ipairs(self.lvl.map.layers) do
        --print(layer.name)
        if layer.type == "tilelayer" then --Check pos ?
            self.lvl.map:drawLayer(layer)
        end
    end

   --[[ local items, len = gameState.states["InGame"].world:getItems()
    for i = 1, len do
        local x, y, w, h = gameState.states["InGame"].world:getRect(items[i])
        if items[i].isObstacle or items[i].health ~= nil then
            love.graphics.rectangle("line", x, y, w, h)
        end
    end--]]


    -- Draw the player and road users
    self:drawAllCars()

    if self.eject then
        self.ejection:render()
    end

    -- Reset transformations
    love.graphics.origin()

    -- Flip horizontally and scale the canvas
    --love.graphics.translate(0, heightWindow)
    --love.graphics.scale(1, 1)

    -- Set the default canvas
    love.graphics.setCanvas()

    -- Draw the preRenderCanvas to the screen
    love.graphics.draw(preRenderCanvas)

    --Use another canvas for UI ?

    -- Reset transformations
    --[[love.graphics.origin()

    love.graphics.translate(0, 0)
    love.graphics.scale(1, 1)--]]
    

    -- Draw UI elements
    for _, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end

    -- Temp life count and score
    if self.inCar then
        love.graphics.print("life: "..self.player.health.."/"..self.player.maxHealth, 10, 40)
    end

    love.graphics.print("score: "..math.abs(math.ceil(self.stats.scores.current-0.5)), 150, 40)

    --love.graphics.print('x: '..input.state.accelerometer.x..'\n\ny: '..input.state.accelerometer.y..'\n\nz: '..input.state.accelerometer.z.."\nrotX: "..rotation, 5, 80)

    love.graphics.print("LVL: "..self.difficulty.id, widthWindow-100, 40)



end


function InGame:setDifficulty(indexDifficulty)
    self.difficulty = self.difficulties[indexDifficulty]
end

function InGame:createWorld()
    local world = bump.newWorld()

    return world
end

function InGame:createMap()
    local lvl = Map(TILEDIM, TILEDIM, 
    "assets/textures/roads/street2/spritesheet.png",
    --"assets/textures/roads/street2/spritesheet.png",
    {
        --street1 = {path="assets/maps/street1.lua", ratio=1},
        --street2 = {path="assets/maps/street2.lua", ratio=0.5},
        street3 = {path="assets/maps/street3.lua", ratio=1},
        --chunk2 = {path="assets/maps/chunk2.lua", ratio=0.5},
        --chunk3 = {path="assets/maps/chunk3.lua", ratio=0.5}
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

function InGame:getRandomCarModel()
    local randCar = nil
    local cumulativeRatio = 0
    local randomValue = math.random()

    for _, model in pairs(self.carModels) do
        cumulativeRatio = cumulativeRatio + model.ratio
        if randomValue <= cumulativeRatio then
            return model.car
        end
    end
end

function InGame:addCarToPathAtPosY(car, path, posY)
    local x = path.x+TILEDIM/2-car.widthCar/2
    if not car.isPolice then
        c = car:castToRoadUser(x, posY, path.direction)
    else
        c = car:castToPolice(x, posY, path.direction)
    end
    table.insert(self.cars, c)
end

function InGame:addCarRandomly()
    local randCarModel = self:getRandomCarModel()
    local randPosY = self.player.y - heightRes - math.random(0, 800)

    local filterPaths = function(item) --Detect paths
        return item.isPath
    end

    local paths, lenPaths = self.world:querySegment(0, randPosY, self.lvl.mapConfig.width*self.lvl.tileWidth, randPosY, filterPaths)

    if lenPaths > 0 then
        randNbPath = math.random(1, lenPaths)
        randomPath = paths[randNbPath]

        local filterCars = function(item) --Add to a class function
            return item.className == "RoadUser" or item.className == "Police"
        end

        local _, nbNearCars = self.world:querySegment(randomPath.x+randomPath.width/2, randPosY-randCarModel.heightCar*2, randomPath.x+randomPath.width/2, randPosY+randCarModel.heightCar, filterCars)
        if nbNearCars == 0 then
            self:addCarToPathAtPosY(randCarModel, randomPath, randPosY)
            print("spawn", randomPath.direction)
        end
        
    end
end

function InGame:deleteOldCars(posYStartingRemoving)
    local cars = gameState.states["InGame"].cars
    
    for _, car in ipairs(cars) do
        if car.y <= posYStartingRemoving then
            car:destroy()
        end
    end
end

function InGame:createUI()
    local UIElements = {}

    UIElements["fuelGauge"] = FuelGauge(
        widthWindow*0.05, 
        heightWindow*0.95, 
        widthWindow*0.9, 
        widthWindow*0.04, 
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
        player.anim:draw(player.spriteSheet, player.x+player.widthCar, player.y+player.heightCar, nil, 1, 1, player.widthCar, player.heightCar)
    end
    for _, car in ipairs(self.cars) do
        if car.direction == "left" then
            car.anim:draw(car.spriteSheet, car.x, car.y+car.heightCar, math.pi, 1, -1, car.widthCar, car.heightCar)
        else
            car.anim:draw(car.spriteSheet, car.x+car.widthCar, car.y+car.heightCar, nil, 1, 1, car.widthCar, car.heightCar)
        end
    end
end

function InGame:manageCamera() 
    local player, ejection = self.player, self.ejection
    local trX, trY = 0, 0

    local function calculateMiddle(entity, widthOffset)
        widthOffset = widthOffset or 0
        return -entity.x*self.zoom + widthRes/2 - widthOffset
    end

    local function calculateCameraOffset(offsetX, middle, widthOffset)
        widthOffset = widthOffset or 0
        if offsetX > 0 then
            return math.min(0, math.max(middle + (offsetX - widthOffset)*ratioScale, -widthRes + offsetX/ratioScale))
        else
            return math.min(0, math.max(middle, -widthRes*(self.zoom-1)))
        end
    end

    if self.inCar then
        local playerMiddle = calculateMiddle(player, player.widthCar)
        trX = calculateCameraOffset(offsetXCamera, playerMiddle, player.widthCar)
        trY = math.max(heightWindow/ratioScale, -player.y*self.zoom + widthWindow/2 + offsetYMap/ratioScale)
    elseif self.eject then
        local ejectionMiddle = calculateMiddle(ejection)
        trX = calculateCameraOffset(offsetXCamera, ejectionMiddle)
        trY = math.max(heightWindow/ratioScale, -ejection.y*self.zoom + widthWindow/2 + offsetYMap/ratioScale)
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