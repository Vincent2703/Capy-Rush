function love.load()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    widthWindow, heightWindow = 350, 622

    pause = false

    loadLibraries()
    loadClasses()

    initScreen()

    world = wf.newWorld(0, 0)
    initMap()

    push.setupScreen(352, 626, {upscale = "normal"})

    player = Player(push.getWidth()/2, 50, "car1", 400)

    input = Input()  
end

function love.update(dt)
    input:update()

    if input.state.actions.newPress.eject then
        local l = createLayer("chunk2")
        --l.name = "test"
        table.insert(layers, l)
        map = createMap()
        print("ok")
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
        cameraX = math.max(0, math.min(cameraX, mapWidth - push.getWidth()))
        cameraY = math.max(0, math.min(cameraY, map.height*map.tileheight - push.getHeight()))

    end
end

function love.draw()
    push.start()
    love.graphics.translate(0, heightWindow)
    love.graphics.scale(1, -1)
    love.graphics.translate(-cameraX, -cameraY)

    for i=1, #map.layers do 
        local layer = map.layers[i]
        if layer.type == "tilelayer" then
            map:drawLayer(layer)
        end
    end

    player.anim:draw(player.spriteSheet, player.x, player.y, math.pi, 1, 1, player.widthCar, player.heightCar)
    world:draw()
    push.finish()
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
    require("classes/Car")
    require("classes/CarSubclasses/Player")
    require("classes/Input")
end

function initScreen()
    windowFlags = {vsync=1, fullscreen=false, resizable=true}
    love.window.setMode(widthWindow, heightWindow, windowFlags)
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	canvas = love.graphics.newCanvas(widthWindow, heightWindow)
end

function initMap()
    nbChunksPerIter = 2
    layers = {}
    local tileWidth, tileHeight = 32, 32

    chunks = {
        chunk1 = {path="assets/maps/chunk1.lua", ratio=0.6},
        chunk2 = {path="assets/maps/chunk2.lua", ratio=0.4}
    }

    map = {
        orientation = "orthogonal",
        width = 11,
        height = 50,
        tilewidth = tileWidth,
        tileheight = tileHeight,
        tilesets = {},
        layers = {}
    }

    local tilesetPath = "assets/textures/roads/tileset.png"
    local tileset = {
        name = "roads",
        firstgid = 1,
        tilewidth = tileWidth,
        tileheight = tileHeight,
        spacing = 0,
        margin = 0,
        image = tilesetPath,
        tileoffset = {x = 0, y = 0},
        tiles = {}
      }
    tileset.imagewidth, tileset.imageheight = love.graphics.newImage(tilesetPath):getDimensions()
    tileset.tilecount = math.ceil((tileset.imagewidth*tileset.imageheight)/(tileWidth*tileHeight))
    table.insert(map.tilesets, tileset)

    table.insert(layers, createLayer("chunk1")) -- Starting chunk
    table.insert(layers, createLayer("chunk2"))
    map = createMap()

	mapWidth, mapHeight = map.width*map.tilewidth, map.height*map.tileheight


	--[[if map.layers["Walls"] then
		for i, obj in pairs(map.layers["Walls"].objects) do
			local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
			wall:setType("static")
		end
	end--]]
end

function addRandomChunksToMap()
    for i=1, nbChunksPerIter do
        local randomValue = math.random()
        local cumulativeRatio = 0

        for chunkName, chunk in pairs(chunks) do
            cumulativeRatio = cumulativeRatio + chunk.ratio
            if randomValue <= cumulativeRatio then
                addChunkToMap(chunkName)
                break
            end
        end
    end
end

function createLayer(chunkName) 
    local chunk = require("assets/maps/"..chunkName)
    local y = 0 --

    if #layers > 0 then
        map.height = map.height + chunk.height -- A déplacer to setMap()
        y = (map.height-chunk.height)*map.tileheight
    end
    local layer = {
        type = "tilelayer", 
        name = chunkName,
        x = 0,
        y = y,
        width = chunk.width,
        height = chunk.height,
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        properties = {},
        encoding = "lua",
        data = chunk.data
    }
    return layer
end

function createMap()
    local tileWidth, tileHeight = 32, 32

    local m = {
        orientation = "orthogonal",
        width = 11,
        height = map.height,
        tilewidth = tileWidth,
        tileheight = tileHeight,
        tilesets = {},
        layers = {}
    }

    local tilesetPath = "assets/textures/roads/tileset.png"
    local tileset = {
        name = "roads",
        firstgid = 1,
        tilewidth = tileWidth,
        tileheight = tileHeight,
        spacing = 0,
        margin = 0,
        image = tilesetPath,
        tileoffset = {x = 0, y = 0},
        tiles = {}
      }
    tileset.imagewidth, tileset.imageheight = love.graphics.newImage(tilesetPath):getDimensions()
    tileset.tilecount = math.ceil((tileset.imagewidth*tileset.imageheight)/(tileWidth*tileHeight))
    table.insert(m.tilesets, tileset)

    m.layers = deepCopy(layers)

    return sti(m)
end

function deepCopy(orig) -- http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end