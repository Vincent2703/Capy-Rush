InGame = class("InGame")

function InGame:init()
    self.zoom = 2.5
    
    self.difficulties = {
        {id = 1, rate = 0.6, nbMaxCars = 2, speed = 1},
        {id = 2, rate = 0.7, nbMaxCars = 2, speed = 1.1},
        {id = 3, rate = 0.7, nbMaxCars = 3, speed = 1.2},
        {id = 4, rate = 0.8, nbMaxCars = 3, speed = 1.3},
        {id = 5, rate = 0.8, nbMaxCars = 4, speed = 1.4},
        {id = 6, rate = 0.9, nbMaxCars = 4, speed = 1.5},
        {id = 7, rate = 0.9, nbMaxCars = 5, speed = 1.6},
    }

    self.carModels = self:createCarsModels()
end

function InGame:start() -- On restart
    self.world = self:createWorld()

    self.lvl = self:createMap()

    local modelCar = self.carModels.car3.car
    self.player = modelCar:castToPlayer(self.lvl.mapChunks[1].paths[1].x+TILEDIM/2-modelCar.widthCar/2, -50)
    self.player.velocity.y, self.player.velocity.x = 0, 0
    self.player.fuel = 100
    self.player.health = self.player.maxHealth
    self.player.isExploding = false
    --self.player.posScreen = {x=0, y=0} 

    self.UI = self:createUI()

    self.difficulty = self.difficulties[1]

    self.stats = Stats()

    self.spawningDistance = 300
    self.distanceCount = 0
    self.prevYPos = 0

    self.cars = {}

    self.landingStatus = false
    self.quickLanding = false
    self.eject = false
    self.ejection = nil

    --[[self.memoryCalls = 0
    self.memoryTotal = 0
    self.memoryMax = 0--]]

    self.camMap, self.camScreen = {x=0, y=0}, {x=0, y=0}
end

function InGame:update(dt)
    if gameState:isCurrentState("InGame") then --useful ?
        soundManager:setMusicVolume(1)

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
                    soundManager:playSFX("splatter")
                    gameState:setState("GameOver", true)
                    return
                else
                    soundManager:playSFX("vroom2")
                    local car = self.cars[self.ejection.landOn]
                    if car.direction == "left" then
                        soundManager:playSFX("tireScreech")
                        self.stats.multipliers.glob = 2
                        self.stats.GUI.reverse.visible = true
                    else
                        self.stats.multipliers.glob = 1
                        self.stats.GUI.reverse.visible = false
                    end
                    self.player = self.player:switchCar(car) --bug when the old car is already destroyed
                    if self.quickLanding then
                        self.stats:addPoints("ejectionsQuickLanding")
                    else
                        self.stats:addPoints("ejectionsNoQuickLanding")
                    end
                end
            end
        else
            if self.stats.scores.current >= self.difficulty.id*50 and self.difficulty.id < #self.difficulties then
                self:setDifficulty(self.difficulty.id+1)
            end

            if self.player.onFire then
                self.stats.multipliers.glob = 2
                self.stats.GUI.onFire.visible = true
                self.stats.GUI.reverse.visible = false
            elseif self.player.direction == "left" then
                self.stats.multipliers.glob = 2
                self.stats.GUI.reverse.visible = true
                self.stats.GUI.onFire.visible = false
            else
                self.stats.multipliers.glob = 1
                self.stats.GUI.onFire.visible = false
                self.stats.GUI.reverse.visible = false
            end
        end

        --to refactorise
        for _, ui in pairs(self.UI) do 
            if not self.eject --[[and ui.visible--]] then
                ui:update()
            end
        end

        for _, elem in pairs(self.stats.GUI) do
            if elem.visible then
                elem:update(dt)
            end
        end

        self:updateAllCars(dt)
        if self.player == nil and not self.eject then
            gameState:setState("GameOver", true)
            return
        end

        if not self.eject then
            if self.player.fuel <= 0 and self.player.velocity.y == 0 then
                gameState:setState("GameOver", true)
                return
            end

            if self.player.y <= -self.lvl.map.height*TILEDIM + HEIGHTRES*1.5 then
                self.check = false
                self.lvl:manageChunks()
                self:deleteOldCars(self.player.y+HEIGHTRES)
            end

            local dist = self.prevYPos-self.player.y
            self.stats:addPoints("distance", dist)
            self.distanceCount = self.distanceCount + dist
            self.prevYPos = self.player.y
            if self.distanceCount >= self.spawningDistance then
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
        if self.stats.scores.current > self.stats.scores.best then
            self.stats.scores.best = math.ceil(self.stats.scores.current-0.5)
        end
    end
    self.camMap = {x=self.player and self.player.x or (self.ejection and self.ejection.x or 0), y=self.player and self.player.y or (self.ejection and self.ejection.y or 0)}
end

function InGame:render()
    -- Set the canvas as the render target
    love.graphics.setCanvas(preRenderCanvas)

    love.graphics.translate(self:manageCamera())
    love.graphics.scale(self.zoom, self.zoom)


    self.camScreen.x, self.camScreen.y = love.graphics.transformPoint(self.camMap.x, self.camMap.y)

    -- Draw the map layers
    for _, layer in ipairs(self.lvl.map.layers) do
        if layer.type == "tilelayer" and self.camMap.y-heightWindow <= layer.y+layer.height*TILEDIM and self.camMap.y+heightWindow >= layer.y then
            if self.eject and layer.name == "signs" then
                layer.opacity = 0.5
            elseif not self.eject and layer.name == "signs" and layer.opacity == 0.5 then
                layer.opacity = 1
            end

            if layer.name == "vegetation" then
                -- Draw the player and road users
                self:drawAllCars()
            end
            self.lvl.map:drawLayer(layer)
        end
    end

    --[[love.graphics.setColor(255, 0, 0)
   local items, len = gameState.states["InGame"].world:getItems()
    for i = 1, len do
        local x, y, w, h = gameState.states["InGame"].world:getRect(items[i])
        if items[i].isObstacle or items[i].health ~= nil then
            love.graphics.rectangle("line", x, y, w, h)
        end
    end
    love.graphics.setColor(255, 255, 255)--]]

    if self.eject then
        self.ejection:draw()
    end

    -- Reset transformations
    love.graphics.origin()

    -- Set the default canvas
    love.graphics.setCanvas()

    -- Draw the preRenderCanvas to the screen
    love.graphics.draw(preRenderCanvas)


    -- Draw UI elements
    for _, ui in pairs(self.UI) do
        if not self.eject --[[and ui.visible--]] then
            ui:draw()
        end
    end


    for _, elem in pairs(self.stats.GUI) do
        if elem.visible and not self.eject then
            elem:draw(dt)
        end
    end
--[[
    love.graphics.print("score: "..math.abs(math.ceil(self.stats.scores.current-0.5)), 150, 40)
    love.graphics.print("highscore: "..math.abs(self.stats.scores.best), 150, 60)

    --love.graphics.print('x: '..input.state.accelerometer.x..'\n\ny: '..input.state.accelerometer.y..'\n\nz: '..input.state.accelerometer.z.."\nrotX: "..rotation, 5, 80)

    --]]

    --[[self.memoryCalls = self.memoryCalls+1 
    local memory = math.ceil(collectgarbage('count')-0.5)
    if self.memoryMax < memory then
        self.memoryMax = memory
    end
    self.memoryTotal = self.memoryTotal + memory
    love.graphics.print('Memory (kB): ' .. memory, 10,500)
    love.graphics.print('Memory avg (kB): ' .. math.ceil(self.memoryTotal/self.memoryCalls-0.5), 10,600)
    love.graphics.print('Memory max (kB): ' .. self.memoryMax, 10,700)--]]

    --love.graphics.line(widthWindow/2, 0, widthWindow/2, heightWindow)
end


function InGame:setDifficulty(indexDifficulty)
    self.difficulty = self.difficulties[indexDifficulty]
end

function InGame:createWorld()
    local world = bump.newWorld()

    return world
end

function InGame:createMap()
    local function getDataLvl(name)
        return require("assets/maps/"..name)
    end
    local lvl = Map(
    "assets/textures/tiles/spritesheet.png",
    {
        chunk1 = {data=getDataLvl("chunk1"), ratio=0.1},
        chunk2 = {data=getDataLvl("chunk2"), ratio=0.05},
        chunk3 = {data=getDataLvl("chunk3"), ratio=0.05},
        chunk4 = {data=getDataLvl("chunk4"), ratio=0.4},
        chunk5 = {data=getDataLvl("chunk5"), ratio=0.05},
        chunk6 = {data=getDataLvl("chunk6"), ratio=0.025},
        --chunk7 = {data=getDataLvl("chunk7"), ratio=0.025},
        chunk8 = {data=getDataLvl("chunk8"), ratio=0.3},
    }, 5, "chunk4")

    return lvl
end

function InGame:createCarsModels()
    local function getSpritesData(filename, widthSprite, heightSprite) 
        local spritesheet = love.graphics.newImage("assets/textures/cars/"..filename..".png")
        local spritesheetWidth, spritesheetHeight = spritesheet:getDimensions()

        return {
                spritesheet = spritesheet, 
                grid = anim8.newGrid(widthSprite, heightSprite, spritesheetWidth, spritesheetHeight, 0, 0, 1), 
                widthSprite = widthSprite, 
                heightSprite = heightSprite
            }
    end

    local carModels = {
        car1 = {car = Car(getSpritesData("car1", 32, 35), 315, 5, 4, -2), ratio=0.2},
        car2 = {car = Car(getSpritesData("car2", 28, 32), 305, 6, 4.5, -2), ratio=0.1},
        car3 = {car = Car(getSpritesData("car3", 28, 37), 280, 5, 3.7, -2), ratio=0.5},
        taxi = {car = Car(getSpritesData("taxi", 28, 37), 275, 6, 3.5, -2), ratio=0.1},
        sport1 = {car = Car(getSpritesData("sport1", 30, 31), 325, 3, 5.5), ratio=0.05},
        police = {car = Car(getSpritesData("police1", 28, 35), 320, 5, 3.5, -2, true), ratio=0.05}
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
    local min = self.player.y+offsetYMap-HEIGHTRES
    local randPosY = math.random(min-HEIGHTRES, min)

    local filterPaths = function(item) --Detect paths
        return item.isPath
    end

    local paths, lenPaths = self.world:querySegment(0, randPosY, self.lvl.mapConfig.width*TILEDIM, randPosY, filterPaths)

    if lenPaths > 0 then
        randNbPath = math.random(1, lenPaths)
        randomPath = paths[randNbPath]

        local filterCars = function(item) --Add to a class function
            return item.className == "RoadUser" or item.className == "Police"
        end

        local _, nbNearCars = self.world:querySegment(randomPath.x+randomPath.width/2, randPosY-randCarModel.heightCar*3, randomPath.x+randomPath.width/2, randPosY+randCarModel.heightCar*4, filterCars)
        if nbNearCars == 0 then
            self:addCarToPathAtPosY(randCarModel, randomPath, randPosY)
        end
        
    end
end

function InGame:deleteOldCars(posYStartingRemoving)
    local cars = gameState.states["InGame"].cars
    
    for _, car in ipairs(cars) do
        if car.y > posYStartingRemoving then
            car:destroy()
        end
    end
end

function InGame:createUI()
    local UIElements = {}

    UIElements.pause = CircleButton(
        math.ceil(widthWindow*0.95)-25,
        math.max(math.ceil(heightWindow*0.05)-25, SAFEZONE.Y),
        50,
        50,
        true,
        "| |",
        {1,1,1},
        {1,1,1, 0.5},
        false,
        function() gameState:setState("Pause", true) end
    )

    UIElements.settings = RectangleButton(
        math.ceil(widthWindow*0.95)-75,
        math.max(math.ceil(heightWindow*0.05)-17, SAFEZONE.Y),
        50,
        50,
        true,
        globalAssets.images.settingsIcon,
        {1,1,1},
        {1,1,1, 0.5},
        false,
        function() gameState:setState("Options", true) end
    )

    UIElements.fuelGauge = FuelGauge(
        math.ceil(widthWindow*0.05), 
        math.ceil(heightWindow*0.95), 
        math.ceil(widthWindow*0.9), 
        math.ceil(widthWindow*0.04), 
        true
    )

    return UIElements
end

function InGame:updateAllCars(dt)
    if self.player then
        self.player:update(dt)
    end

    for _, car in ipairs(self.cars) do
        if car.y < self.camMap.y+offsetYMap and car.y > self.camMap.y-heightWindow and car.x > self.camMap.x-widthWindow and car.x < self.camMap.x+widthWindow then
            car:update(dt)
        end
    end
end

function InGame:drawAllCars()
    if self.player then
        self.player:draw()
    end
    for _, car in ipairs(self.cars) do
        if car.y < self.camMap.y+offsetYMap and car.y > self.camMap.y-heightWindow and car.x > self.camMap.x-widthWindow and car.x < self.camMap.x+widthWindow then
            car:draw()
        end
    end
end
function InGame:manageCamera() 
    local player, ejection = self.player, self.ejection
    local trX, trY = 0, 0

    local entity = self.eject and ejection or player
    local entityWidth = self.eject and self.lastPlayerWidth or player.widthCar
    local entityX = entity.x - (self.eject and self.lastPlayerWidth / 2 or 0)

    trX = math.min(0, math.max(-entityX * self.zoom - entityWidth / 2 * self.zoom + WIDTHRES / 2, -WIDTHRES * self.zoom + widthWindow / ratioScale))

    trY = math.max(heightWindow / ratioScale, -entity.y * self.zoom + TILEDIM / ratioScale * 13.5)

    return trX, trY
end


function InGame:manageEjection(ejection)
    if ejection then
        self.quickLanding = false
        self.landingStatus = false
        self.eject = true
        self.ejection = Ejection(self.player.x+self.player.widthCar/2, self.player.y+self.player.heightCar/2)
        self.player.isExploding = true
        self.lastPlayerWidth = self.player.widthCar
    else
        self.quickLanding = true
        self.landingStatus = true
        self.ejection.velocity.x, self.ejection.velocity.y = self.ejection.velocity.x/2, self.ejection.velocity.y/2
        self.ejection.maxSpeed = self.ejection.maxSpeed/2
    end
end