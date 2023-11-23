function love.load()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    widthRes, heightRes = 352, 626
    widthWindow, heightWindow = 352, 626

    pause = false

    loadLibraries()
    loadClasses()

    initScreen()

    local font = love.graphics.newFont("assets/fonts/FFFFORWA.ttf", 14)
    love.graphics.setFont(font)

    world = wf.newWorld(0, 0)
    lvl = Map(32, 32, 
    "assets/textures/roads/tileset.png",
    {
        chunk1 = {path="assets/maps/chunk1.lua", ratio=0.6},
        chunk2 = {path="assets/maps/chunk2.lua", ratio=0.4}
    }, 5)

    createCarModels()

    player = carModels.car1:castToPlayer(widthRes/2, 50)

    roadUsers = {}
    table.insert(roadUsers, car)

    for _, chunk in pairs(lvl.mapChunks) do
        addRandomCars(chunk)
    end

    input = Input()  

    createUI()
end

function love.update(dt)
    input:update()

    if input.state.actions.newPress.eject then
        print(lvl:getLayerAtPos(player.y))
    end

    for key, ui in pairs(UIElements) do 
        if ui.visible then
            ui:update()
        end
    end

    if input.state.actions.newPress.pause then
		pause = not pause
	end

    if not pause then
        player:move(dt)
        for _, roadUser in pairs(roadUsers) do
            roadUser:move(dt)
        end
        world:update(dt)

        manageCamera()

        if player.y >= lvl.map.height*lvl.tileHeight - heightRes*1.5 then
            lvl:manageChunks()
            for _, chunk in pairs(lvl.mapChunks) do
                addRandomCars(chunk)
            end
        end
    end
end

function love.draw()
    -- Set the canvas as the render target
    love.graphics.setCanvas(preRenderCanvas)

    love.graphics.translate(0, (-cameraY)+camYOffset)

    -- Draw the map layers
    for i = 1, #lvl.map.layers do
        local layer = lvl.map.layers[i]
        if layer.type == "tilelayer" then
            lvl.map:drawLayer(layer)
        end
    end

    -- Draw the player and collision boxes
    player.anim:draw(player.spriteSheet, player.x, player.y, math.pi, 1, 1, player.widthCar, player.heightCar)
    for _, roadUser in pairs(roadUsers) do
        roadUser.anim:draw(roadUser.spriteSheet, roadUser.x, roadUser.y, math.pi, 1, 1, roadUser.widthCar, roadUser.heightCar)
    end
    world:draw() 
    
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
    --love.graphics.rectangle("line", 0, 0, widthRes, heightRes)

    for key, ui in pairs(UIElements) do
        if ui.visible then
            ui:draw()
        end
    end
end



function love.resize(width, height)
    -- Update window dimensions
    widthWindow, heightWindow = width, height

    -- Resize canvas
    canvas = love.graphics.newCanvas(widthWindow, heightWindow)

    ratioScale = math.min(widthWindow/widthRes, heightWindow/heightRes)
    offsetXCanvas = widthWindow/2-(widthRes/2)*ratioScale

    if heightWindow/heightRes > widthWindow/widthRes then
        camYOffset = heightWindow-heightRes*ratioScale
        preRenderCanvas = love.graphics.newCanvas(widthRes, heightRes+camYOffset)
    else
        camYOffset = 0
    end
end

--

function loadLibraries()
	anim8 = require("libraries/anim8/anim8")
	class = require("libraries/30log/30log-clean")
	sti = require("libraries/sti")
	wf = require("libraries/windfield")
    push = require("libraries/push/push")
end

function loadClasses()
    require("classes/Map")

    require("classes/Car")
    require("classes/CarSubclasses/Player")
    require("classes/CarSubclasses/RoadUser")

    require("classes/UI")
    require("classes/UISubclasses/FuelGauge")
    require("classes/UISubclasses/Button")
    require("classes/UISubclasses/ButtonSubclasses/RectangleButton")
    require("classes/UISubclasses/ButtonSubclasses/CircleButton")

    require("classes/Input")
end

function initScreen()
    windowFlags = {vsync=1, fullscreen=false, resizable=true}
    love.window.setMode(widthWindow, heightWindow, windowFlags)
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	canvas = love.graphics.newCanvas(widthWindow, heightWindow)
    preRenderCanvas = love.graphics.newCanvas(widthRes, heightRes)
    ratioScale = math.min(widthWindow/widthRes, heightWindow/heightRes)
    offsetXCanvas = widthWindow/2-(widthRes/2)*ratioScale

    camYOffset = 0
end

function createUI()
    --UICanvas = love.graphics.newCanvas(widthRes, heightRes)
    UIElements = {}

    UIElements["fuelGauge"] = FuelGauge(
        10, 
        heightRes-30, 
        widthRes-20, 
        20, 
        true, 
        player
    )
    UIElements["brakeBtn"] = RectangleButton(
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
    )
    UIElements["ejectBtn"] = CircleButton(
        widthRes/2-25,-- min(width, height)/2
        UIElements["brakeBtn"].y,
        math.floor(widthRes/3),
        50,
        true,
        "!!",
        {255, 0, 0},
        nil,
        function() print("eject !") end
    )
end

function manageCamera()
    cameraY = math.max(0, math.min(player.y - player.heightCar-64, lvl.map.height*lvl.tileHeight - heightRes)) --Or heightWindow
end

function createCarModels()
    carModels = {
        car1 = Car("car1", 32, 35, 400, 1),
        car2 = Car("car2", 32, 35, 0, 3.2)
    }
end

function addRandomCars(chunk)
    local nbCars = 1--math.random(1, lvl.nbChunksPerIter*3)
    
    for i=1, nbCars do
        local rand = math.random(1, #chunk.paths)
        local randomPath = chunk.paths[rand]
        carY = math.random(randomPath.y, randomPath.y+randomPath.height)
        local car = carModels.car2:castToRoadUser(randomPath.x+randomPath.width/2, carY)
        table.insert(roadUsers, car)
    end

end