function love.load()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    widthRes, heightRes = 352, 626
    widthWindow, heightWindow = 350, 622

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

    push.setupScreen(widthRes, heightRes, {upscale = "normal"})

    player = Player(push.getWidth()/2, 50, "car1", 400, 3)

    input = Input()  

    createUI()
end

function love.update(dt)
    input:update()

    for key, ui in pairs(UIElements) do 
        if ui.visible then
            ui:update()
        end
    end

    if input.state.actions.newPress.eject then

    end

    if input.state.actions.newPress.pause then
		pause = not pause
	end

    if not pause then
        player:move(dt)
        world:update(dt)

        -- Adjust the camera to follow the player
        cameraX = player.x - push.getWidth()/2 + player.widthCar/2
        cameraY = player.y - player.heightCar-64

        -- Ensure the camera doesn't go outside the map boundaries
        cameraX = math.max(0, math.min(cameraX, lvl.mapWidth - push.getWidth()))
        cameraY = math.max(0, math.min(cameraY, lvl.map.height*lvl.tileHeight - push.getHeight()))

        if player.y >= lvl.map.height*lvl.tileHeight - heightRes*1.5 then
            lvl:manageMapChunks()
        end
    end
end

function love.draw()
    love.graphics.setCanvas(preRenderCanvas)

    push.start()
    love.graphics.translate(-cameraX, -cameraY)

    for i=1, #lvl.map.layers do 
        local layer = lvl.map.layers[i]
        if layer.type == "tilelayer" then
            lvl.map:drawLayer(layer)
        end
    end

    player.anim:draw(player.spriteSheet, player.x, player.y, math.pi, 1, 1, player.widthCar, player.heightCar)
    world:draw()
    push.finish()
    love.graphics.translate(0, heightWindow)
    love.graphics.scale(1, -1)
    love.graphics.setCanvas()
    love.graphics.draw(preRenderCanvas)
    -- To fix when resize
    love.graphics.origin()
    for key, ui in pairs(UIElements) do 
        if ui.visible then
            ui:draw()
        end
    end
end

function love.resize(width, height)
	push.resize(width, height)
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
	
	canvas, preRenderCanvas = love.graphics.newCanvas(widthWindow, heightWindow)
    preRenderCanvas = love.graphics.newCanvas(widthWindow, heightWindow)
end

function createUI()
    UICanvas = love.graphics.newCanvas(widthRes, heightRes)
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
        widthRes-widthRes/3,
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