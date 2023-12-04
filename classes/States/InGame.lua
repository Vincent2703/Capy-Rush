InGame = class("InGame")

function InGame:init()
    local function createWorld()
        local world = bump.newWorld()

        return world
    end

    self.world = createWorld()

    self.cameraY = 0

    self.difficulties = {
        {rate = 0.5, nbMaxCars = 1},
        {rate = 0.5, nbMaxCars = 2},
        {rate = 0.6, nbMaxCars = 2},
        {rate = 0.7, nbMaxCars = 2},
        {rate = 0.7, nbMaxCars = 3},
        {rate = 0.8, nbMaxCars = 3},
        {rate = 0.8, nbMaxCars = 4}
    }
end

function InGame:start() -- Because need gameState.currentState.world variable
    local function createMap()
        local lvl = Map(48, 48, 
        "assets/textures/roads/tileset.png",
        {
            chunk1 = {path="assets/maps/chunk1.lua", ratio=0.6},
            chunk2 = {path="assets/maps/chunk2.lua", ratio=0.4}
        }, 5)

        return lvl
    end

    local function createCarsModels()
        local carModels = {
            car1 = Car("car1", 32, 35, 400, 0.1),
            car2 = Car("car2", 32, 35, 450, 3.2)
        }

        return carModels
    end

    local function createUI()
        local UIElements = {}

        UIElements["fuelGauge"] = FuelGauge(
            10, 
            heightRes-30, 
            widthRes-20, 
            20, 
            true, 
            self.player
        )
        --[[UIElements["brakeBtn"] = RectangleButton(
            UIElements["fuelGauge"].x, 
            UIElements["fuelGauge"].y-55, 
            math.floor(widthRes/3), 
            50, 
            true, 
            "BRAKE", 
            nil,
            nil,
            function() input.state.actions.brake = true end
        )
        UIElements["boostBtn"] = RectangleButton(
            widthRes-widthRes/3-UIElements["fuelGauge"].x,
            UIElements["brakeBtn"].y, 
            math.floor(widthRes/3),
            50,
            true,
            "BOOST",
            nil,
            nil,
            function() input.state.actions.boost = true end
        )--]]
        UIElements["ejectBtn"] = CircleButton(
            widthRes/2-25,-- min(width, height)/2
            UIElements["fuelGauge"].y-55,
            math.floor(widthRes/3),
            50,
            true,
            "Eject",
            {255, 0, 0},
            nil,
            function() print("eject !") end
        )

        return UIElements
    end

    self.lvl = createMap()

    self.carModels = createCarsModels()

    self.player = self.carModels.car1:castToPlayer(self.lvl.mapChunks[1].paths[1].x-self.carModels.car1.widthCar/2+self.lvl.tileWidth/2, 50)

    self.UI = createUI()

    self.difficulty = self.difficulties[1]

    self.distanceCount = 0
    self.prevYPos = 0

    self.roadUsers = {}
end

function InGame:update(dt)
    local function updateAllCars(dt)
        self.player:update(dt)
        if self.player.health <= 0 then
            gameState:setState("GameOver", true)
        end
        for _, roadUser in pairs(self.roadUsers) do
            roadUser:update(dt)
        end
    end

    local function manageCamera()
        return math.max(0, math.min(self.player.y - self.player.heightCar-64, self.lvl.map.height*self.lvl.tileHeight - heightRes))
    end

    if gameState:isCurrentState("InGame") then
        if input.state.actions.newPress.pause then
            gameState:setState("Pause", true)
        end

        self.distanceCount = self.distanceCount + self.player.y-self.prevYPos
        self.prevYPos = self.player.y

        for key, ui in pairs(self.UI) do 
            if ui.visible then
                ui:update()
            end
        end

        updateAllCars(dt)

        self.cameraY = manageCamera()

        if self.player.y >= self.lvl.map.height*self.lvl.tileHeight - heightRes*1.5 then
            self.lvl:manageChunks()
            Car:deleteOldRoadUsers(self.player.y-heightRes)
        end

        if self.distanceCount >= 500 then
            self.distanceCount = 0
            local rand = math.random()
            if rand <= self.difficulty.rate then
                local chunk = self.lvl.mapChunks[self.lvl:getNbChunkAtPos(self.player.y)]
                local nbCars = math.random(1, self.difficulty.nbMaxCars)
                for i=1, nbCars do
                    Car:addRandomRoadUser(chunk, self.player.y+heightRes+math.random(0, heightRes))
                end
            end
        end
    end
end

function InGame:render()
    local function drawAllCars()
        local player = self.player
        player.anim:draw(player.spriteSheet, player.x, player.y, math.pi, 1, 1, player.widthCar, player.heightCar)
        for _, roadUser in pairs(self.roadUsers) do
            local flipH = 1
            if roadUser.direction == "left" then
                flipH = -1
            end
            roadUser.anim:draw(roadUser.spriteSheet, roadUser.x, roadUser.y, math.pi, 1, flipH, roadUser.widthCar, roadUser.heightCar)
        end
    end

    -- Set the canvas as the render target
    love.graphics.setCanvas(preRenderCanvas)

    love.graphics.translate(0, (-self.cameraY)+camYOffset)

    -- Draw the map layers
    for i = 1, #self.lvl.map.layers do
        local layer = self.lvl.map.layers[i]
        if layer.type == "tilelayer" then
            self.lvl.map:drawLayer(layer)
        end
    end

    -- Draw the player and collision boxes
    drawAllCars()
    
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
    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end

    -- Temp life count
    love.graphics.print(self.player.health.."/10", 250, 10)
end

function InGame:setDifficulty(indexDifficulty)
    self.difficulty = self.difficulties[indexDifficulty]
end