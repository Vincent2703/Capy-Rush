InGame = class("InGame")

function InGame:init()
    self.zoom = ratioScale >= 1 and 2.5/ratioScale or 2.5
    
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

    self.items = { --To put elsewhere ?
        upDiff = {
            proba = 10,
            fn = function() 
                if self.difficulty.id < #self.difficulties then
                    self:setDifficulty(self.difficulty.id+1)
                    table.insert(self.notifs, ShortNotif("Difficulty up", nil, {1, 0.39, 0}))
                    return true
                end
                return false
            end
        },
        downDiff = {
            proba = 5,
            fn = function()
                if self.difficulty.id > 1 then
                    self:setDifficulty(self.difficulty.id-1)
                    table.insert(self.notifs, ShortNotif("Difficulty down", nil, {0.40, 0.59, 0.45}))
                    return true
                end
                return false
            end
        },
        repair = {
            proba = 15,
            fn = function()
                if self.player.health < self.player.maxHealth then
                    self.player.health = self.player.maxHealth
                    table.insert(self.notifs, ShortNotif("Repaired", nil, {0.40, 0.59, 0.45}))
                    soundManager:playSFX("repair")
                    return true
                end
                return false
            end
        },
        damage = {
            proba = 5,
            fn = function()
                if self.player.health > 1 then
                    self.player.health = self.player.health-1
                    table.insert(self.notifs, ShortNotif("Run over a nail", "-1 health", {1, 0.39, 0}))
                    soundManager:playSFX("tireBurst")
                    return true
                end
                return false
            end
        },
        refuel = {
            proba = 15,
            fn = function()
                if self.player.fuel < 100 then
                    self.player.fuel = 100
                    table.insert(self.notifs, ShortNotif("Refueled", nil, {0.40, 0.59, 0.45}))
                    soundManager:playSFX("refuel")
                    return true
                end
                return false
            end
        },
        leak = {
            proba = 5,
            fn = function()
                if self.player.fuel >= 25 then
                    self.player.fuel = self.player.fuel-20
                    table.insert(self.notifs, ShortNotif("Leak", "-20 fuel", {1, 0.39, 0}))
                    soundManager:playSFX("leak")
                    return true
                end
                return false
            end
        },
        teleport = {
            proba = 10,
            fn = function()
                if self.player.direction == "right" then
                    table.insert(self.notifs, ShortNotif("Teleported", nil, {1, 0.39, 0}))
                    soundManager:playSFX("teleport")

                    local filterPaths = function(item) 
                        return item.isPath and item.direction == "left" and not item.isCar and not item.isObstacle
                    end

                    local paths, lenPaths = self.world:queryRect(0, self.player.y-TILEDIM*5, self.lvl.mapConfig.width*TILEDIM, TILEDIM*5, filterPaths)

                    if lenPaths > 0 then
                        randNbPath = math.random(1, lenPaths)
                        randomPath = paths[randNbPath]

                        self.player:updatePosition(randomPath.x, self.player.y)
                        self.player.velX = 0
                        return true
                    end
                end
                return false
            end
        },
        bonusPoints = {
            proba = 25,
            fn = function()
                self.stats.scores.current = self.stats.scores.current+10
                print("bonus points")
                table.insert(self.notifs, ShortNotif("Bonus points", "+5", {0.40, 0.59, 0.45}))
                return true
            end
        },
        malusPoints = {
            proba = 10,
            fn = function()
                if self.stats.scores.current >= 10 then
                    self.stats.scores.current = self.stats.scores.current-10
                    print("malus points")
                    table.insert(self.notifs, ShortNotif("Malus points", "-5", {1, 0.39, 0}))
                    return true
                end
                return false
            end
        }

    }
end

function InGame:start() -- On restart
    self.tuto = true--save.content.firstTime
    self.freeze = false

    if not self.tuto and love_admob and nbRuns>1 and nbRuns%3 == 0 then
        -- TEMP
        love_admob.requestInterstitial(ads.ads.inter)
    end

    self.world = self:createWorld()

    self.lvl = self:createMap()

    local modelCar = self.carModels.car3.car
    self.player = modelCar:castToPlayer(self.lvl.mapChunks[1].paths[1].x+TILEDIM/2-modelCar.widthCar/2, -50)
    self.player.velocity.y, self.player.velocity.x = 0, 0
    self.player.fuel = 100
    self.player.health = self.player.maxHealth
    self.player.isExploding = false

    self.UI = self:createUI()
    self.notifs = {}

    self.difficulty = self.difficulties[1]

    self.stats = Stats()

    self.spawningDistance = 300
    self.distanceCount = 0
    self.prevYPos = 0

    self.cars = {}

    self.crates = {}
    if self.tuto then
        table.insert(self.crates, Crate(self.lvl.mapChunks[1].paths[1].x, -TILEDIM*12))
    end

    self.landingStatus = false
    self.quickLanding = false
    self.eject = false
    self.ejection = nil

    self.camMap, self.camScreen = {x=0, y=0}, {x=0, y=0}


    if self.tuto then --TODO : class objective
        self.tutoParts = {
            moving = {
                status = nil,
                yStart = 0,
                height = TILEDIM*10,
                ui = MessageBox("To move the car, tilt your phone to the left or to the right.", Utils:round(widthWindow*0.75), function() self.freeze = false end), --Should be a canvas instead
                callback = function() return self.player and self.player.y < -TILEDIM*10 end
            },
            crate = {
                status = nil,
                yStart = -TILEDIM*10,
                height = TILEDIM*15,
                ui = MessageBox("Try to drive over the crate.", Utils:round(widthWindow*0.75), function() self.freeze = false end),
                callback = function() return self.player and 
                    self.player.x >= self.lvl.mapChunks[1].paths[1].x-10 and self.player.x <= self.lvl.mapChunks[1].paths[1].x+10 and self.player.y <= TILEDIM*12+20 and self.player.y >= TILEDIM*12-20 
                    end
            }
        }
    end

    -- To refactorize : (spawn a car at startup)

    local randCarModel = self:getRandomCarModel()

    local filterPaths = function(item) 
        return item.isPath and item.direction == "right"
    end

    local posY = -HEIGHTRES/self.zoom*2

    local paths, lenPaths = self.world:querySegment(0, posY, self.lvl.mapConfig.width*TILEDIM, posY, filterPaths)

    if not self.tuto and lenPaths > 0 then
        randNbPath = math.random(1, lenPaths)
        randomPath = paths[randNbPath]
        self:addCarToPathAtPosY(randCarModel, randomPath, posY)
    end
end

function InGame:update(dt)
    if gameState:isCurrentState("InGame") then --useful ?
        soundManager:setMusicVolume(1)

        if (input.state.actions.newPress.eject 
        or (input.state.actions.newPress.click and input.state.mouse.y <= 0.9*heightWindow and input.state.mouse.y >= 0.1*heightWindow)) 
        and not self.eject and self.player and not self.player.isExploding and not self.freeze then
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
                    if not self.tuto then
                        gameState:setState("GameOver", true)
                    else
                        self:tutoResetPart()
                    end
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
                    --To optimize (bug when the old car is already destroyed)
                    if self.player then
                        self.player = self.player:switchCar(car)
                    else
                        self.player = car:cast(Player)
                        player.direction = "right"
                    
                        self.UI["fuelGauge"].player = player -- optimize
                    end
                    if self.quickLanding then
                        self.stats:addPoints("ejectionsQuickLanding")
                    else
                        self.stats:addPoints("ejectionsNoQuickLanding")
                    end
                end
            end
        elseif self.player then
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

        if self.tuto then
            for _, tutoPart in pairs(self.tutoParts) do
                if self.player and self.player.y < tutoPart.yStart and self.player.y > tutoPart.yStart-tutoPart.height and tutoPart.status == nil then
                    tutoPart.status = "current"
                    tutoPart.ui.visible = true
                    self.freeze = true
                end
                if tutoPart.status == "current" then
                    if tutoPart.callback() then
                        tutoPart.status = "done"
                    end
                    if tutoPart.status == "current" and tutoPart.ui.visible then
                        tutoPart.ui:update(dt)
                    end
                end
            end
        end

        --to refactorize
        for i, crate in ipairs(self.crates) do
            crate:update(dt)
            if not crate.active or crate.y > self.player.y+heightWindow/2 then
                table.remove(self.crates, i)
                self.world:remove(crate)
            end
        end

        for i, notif in ipairs(self.notifs) do
            notif:update(dt)
            if notif.finished then
                table.remove(self.UI, i)
            end
        end

        for _, ui in pairs(self.UI) do 
            if not self.eject then
                ui:update(dt)
            end
        end

        for _, elem in pairs(self.stats.GUI) do
            if elem.visible then
                elem:update(dt)
            end
        end

        if not self.freeze then
            self:updateAllCars(dt)
        end

        if self.player == nil and not self.eject then
            if not self.tuto then
                gameState:setState("GameOver", true)
            else
                self:tutoResetPart()
            end
            return
        end

        if not self.eject then
            if self.player.fuel <= 0 and self.player.velocity.y == 0 then
                if not self.tuto then
                    gameState:setState("GameOver", true)
                else
                    self:tutoResetPart()
                end
                return
            end

            if not self.tuto and self.player.y <= -self.lvl.map.height*TILEDIM + HEIGHTRES*1.5 then
                self.check = false
                self.lvl:manageChunks()
                self:deleteOldCars(self.player.y+HEIGHTRES)
            end

            local dist = self.prevYPos-self.player.y
            self.stats:addPoints("distance", dist)
            self.distanceCount = self.distanceCount + dist
            self.prevYPos = self.player.y
            if self.distanceCount >= self.spawningDistance and not self.tuto then
                self.distanceCount = 0
                local rand = math.random()
                if rand <= self.difficulty.rate then
                    local nbCars = math.random(1, self.difficulty.nbMaxCars)
                    local nbCarsRight, nbCarsLeft = 0, 0
                    for i=1, nbCars do
                        local car = self:addCarRandomly()
                        if car and car.direction == "left" then
                            nbCarsLeft = nbCarsLeft+1
                        else
                            nbCarsRight = nbCarsRight+1
                        end
                    end
                    if nbCarsLeft == 0 then
                        self:addCarRandomly("left")
                    elseif nbCarsRight == 0 then
                        self:addCarRandomly("right")
                    end
                end

                rand = math.random()
                if rand <= 0.08 then
                    local posY = self.player.y+offsetYMap-HEIGHTRES

                    local filterPaths = function(item) --Detect paths
                        return item.isPath and item.direction == self.player.direction
                    end
                
                    local paths, lenPaths = self.world:querySegment(0, posY, self.lvl.mapConfig.width*TILEDIM, posY, filterPaths)
                
                    if lenPaths > 0 then
                        randNbPath = math.random(1, lenPaths)
                        randomPath = paths[randNbPath]

                        table.insert(self.crates, Crate(randomPath.x, self.player.y+offsetYMap-HEIGHTRES-math.random(0, heightWindow)))
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

    if self.player or self.eject then
        love.graphics.translate(self:manageCamera())
    end
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
                -- Draw the player, road users and crates
                for _, crate in pairs(self.crates) do
                    crate:draw()
                end
                self:drawAllCars()
            end
            self.lvl.map:drawLayer(layer)
        end
    end

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

    if self.tuto then
        for _, tutoPart in pairs(self.tutoParts) do
            if tutoPart.status == "current" and tutoPart.ui.visible then
                tutoPart.ui:draw()
            end
        end
    end


    for _, notif in ipairs(self.notifs) do
        if not notif.finished  then
            notif:draw()
        end
    end

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
    local lvl
    
    if self.tuto then
        lvl = Map(
        "assets/textures/tiles/spritesheet.png",
        {
            tuto = {data=getDataLvl("tuto"), proba=100}
        }, 5, "tuto")
    else
        lvl = Map(
        "assets/textures/tiles/spritesheet.png",
        {
            chunk1 = {data=getDataLvl("chunk1"), proba=20},
            chunk2 = {data=getDataLvl("chunk2"), proba=7.5},
            chunk3 = {data=getDataLvl("chunk3"), proba=7.5},
            chunk4 = {data=getDataLvl("chunk4"), proba=40},
            chunk5 = {data=getDataLvl("chunk5"), proba=5},
            chunk6 = {data=getDataLvl("chunk6"), proba=7.5},
            chunk7 = {data=getDataLvl("chunk7"), proba=2.5},
            chunk8 = {data=getDataLvl("chunk8"), proba=10},
        }, 5, "chunk4")
    end

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
        car1 = {car = Car(getSpritesData("car1", 32, 35), 305, 4, 4, -2), proba=20},
        car2 = {car = Car(getSpritesData("car2", 28, 32), 295, 4, 4.5, -2), proba=11},
        car3 = {car = Car(getSpritesData("car3", 28, 37), 270, 4, 3.7, -2), proba=50},
        taxi = {car = Car(getSpritesData("taxi", 28, 37), 265, 5, 3.5, -2), proba=11},
        sport1 = {car = Car(getSpritesData("sport1", 30, 31), 315, 3, 5.5), proba=5},
        police = {car = Car(getSpritesData("police1", 28, 35), 310, 4, 3.5, -2, true), proba=3}
    }

    return carModels
end

function InGame:getRandomCarModel()
    return Utils:weightedRandom(self.carModels).car
end

function InGame:addCarToPathAtPosY(car, path, posY)
    local x = path.x+TILEDIM/2-car.widthCar/2
    if not car.isPolice then
        c = car:castToRoadUser(x, posY, path.direction)
    else
        c = car:castToPolice(x, posY, path.direction)
    end
    table.insert(self.cars, c)

    return c
end

function InGame:addCarRandomly(direction)
    local randCarModel = self:getRandomCarModel()
    local min = self.player.y+offsetYMap-HEIGHTRES
    local randPosY = math.random(min-HEIGHTRES, min)

    local filterPaths = function(item, direction) --Detect paths
        if direction then
            return item.isPath and item.direction == direction
        else
            return item.isPath
        end
    end

    local paths, lenPaths = self.world:querySegment(0, randPosY, self.lvl.mapConfig.width*TILEDIM, randPosY, filterPaths)

    if lenPaths > 0 then
        randNbPath = math.random(1, lenPaths)
        randomPath = paths[randNbPath]

        local filterCars = function(item) --Add to a class function
            return item.className == "RoadUser" or item.className == "Police"
        end

        local _, nbNearCars = self.world:querySegment(randomPath.x+randomPath.width/2, randPosY-randCarModel.heightCar*3, randomPath.x+randomPath.width/2, randPosY+randCarModel.heightCar*5, filterCars)
        if nbNearCars == 0 then
            return self:addCarToPathAtPosY(randCarModel, randomPath, randPosY)
        end
    end
    return false
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
        math.max(math.ceil(heightWindow*0.05)-15, SAFEZONE.Y-4),
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
        math.max(math.ceil(heightWindow*0.05)-7, SAFEZONE.Y),
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
        if car.y < self.camMap.y+offsetYMap+heightWindow and car.y > self.camMap.y-heightWindow and car.x > self.camMap.x-widthWindow and car.x < self.camMap.x+widthWindow then
            car:update(dt)
        end
    end
end

function InGame:drawAllCars()
    if self.player then
        self.player:draw()
    end
    for _, car in ipairs(self.cars) do
        if car.y < self.camMap.y+offsetYMap+heightWindow/2 and car.y > self.camMap.y-heightWindow and car.x > self.camMap.x-widthWindow and car.x < self.camMap.x+widthWindow then
            car:draw()
        end
    end
end
function InGame:manageCamera() 
    local player, ejection = self.player, self.ejection
    local trX, trY = 0, 0

    local entity = self.eject and ejection or player
    local entityWidth = self.eject and self.lastPlayerWidth or player.widthCar
    local entityHeight = self.eject and self.lastPlayerHeight*0.75 or player.heightCar
    local entityX = entity.x - (self.eject and self.lastPlayerWidth / 2 or 0)

    trX = math.min(0, math.max(-entityX * self.zoom - entityWidth / 2 * self.zoom + WIDTHRES / 2, -WIDTHRES * self.zoom + widthWindow / ratioScale))

    trY = math.max(heightWindow / ratioScale, -entity.y * self.zoom + heightWindow/ratioScale-entityHeight*2*self.zoom)

    if self.tuto then
        trY = math.min(self.lvl.mapConfig.height*TILEDIM*self.zoom, trY)
    end

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
        self.lastPlayerHeight = self.player.heightCar
    else
        self.quickLanding = true
        self.landingStatus = true
        self.ejection.velocity.x, self.ejection.velocity.y = self.ejection.velocity.x/2, self.ejection.velocity.y/2
        self.ejection.maxSpeed = self.ejection.maxSpeed/2
    end
end

function InGame:tutoResetPart()
    local items, len = self.world:getItems()
    for i=1, len do
        if items[i].isCar then
            self.world:remove(items[i])
        end
    end
    self.player = nil

    for _, tutoPart in pairs(self.tutoParts) do
        if tutoPart.status == "current" then
            local modelCar = self.carModels.car3.car
            self.player = modelCar:castToPlayer(self.lvl.mapChunks[1].paths[1].x+TILEDIM/2-modelCar.widthCar/2, tutoPart.yStart)
            self.player.velocity.y, self.player.velocity.x = 0, 0
            self.player.fuel = 100
            self.player.health = self.player.maxHealth
            self.player.isExploding = false
            tutoPart.ui.visible = true
            self.freeze = true
        end
    end
end