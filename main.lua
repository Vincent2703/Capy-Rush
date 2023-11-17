function love.load()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    widthWindow, heightWindow = 350, 622

    pause = false

    loadLibraries()
    loadClasses()

    initScreen()

    world = wf.newWorld(0, 0)
    lvl = Map(32, 32, 
    "assets/textures/roads/tileset.png",
    {
        chunk1 = {path="assets/maps/chunk1.lua", ratio=0.6},
        chunk2 = {path="assets/maps/chunk2.lua", ratio=0.4}
    }, 5)

    push.setupScreen(352, 626, {upscale = "normal"})

    player = Player(push.getWidth()/2, 50, "car1", 400)

    input = Input()  
end

function love.update(dt)
    input:update()

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

        if player.y >= lvl.map.height*lvl.tileHeight - heightWindow*1.5 then
            lvl:manageMapChunks()
            print("new")
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
    require("classes/Input")
end

function initScreen()
    windowFlags = {vsync=1, fullscreen=false, resizable=true}
    love.window.setMode(widthWindow, heightWindow, windowFlags)
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	canvas, preRenderCanvas = love.graphics.newCanvas(widthWindow, heightWindow)
    preRenderCanvas = love.graphics.newCanvas(widthWindow, heightWindow)
end