function love.load()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    widthRes, heightRes = 432, 650
    --widthWindow, heightWindow = 432, 650--480, 720

    loadLibraries()
    loadClasses()

    initScreen()

    local font = love.graphics.newFont("assets/fonts/FFFFORWA.ttf", 14)
    love.graphics.setFont(font)

    gameState = GameState()
    gameState:setState("InGame", true)

    input = Input()  
end

function love.update(dt)
    input:update()

    gameState.currentState:update(dt)

end

function love.draw()
    gameState.currentState:render()
end

function love.focus(f)
    if not f then
        gameState:setState("Pause", true)
    end
end


--[[function love.resize(width, height)
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
end--]]

--

function loadLibraries()
	anim8 = require("libraries/anim8/anim8")
	class = require("libraries/30log/30log-clean")
	sti = require("libraries/sti")
    bump = require("libraries/bump/bump")
end

function loadClasses()
    require("classes/Map")

    require("classes/Car")
    require("classes/CarSubclasses/Player")
    require("classes/CarSubclasses/RoadUser")

    require("classes/Ejection")

    require("classes/Stats")

    require("classes/UI")
    require("classes/UISubclasses/FuelGauge")
    require("classes/UISubclasses/Button")
    require("classes/UISubclasses/ButtonSubclasses/RectangleButton")
    require("classes/UISubclasses/ButtonSubclasses/CircleButton")

    require("classes/GameState")
    require("classes/States/InGame")
    require("classes/States/Pause")
    require("classes/States/GameOver")

    require("classes/Input")
end

function initScreen()
    local os = love.system.getOS()
    local flags = {}
    if os == "Android" then
        widthWindow, heightWindow = 0, 0
        flags.resizable = false
        flags.fullscreen = true
    else
        widthWindow, heightWindow = 600, 800
        flags.resizable = false
        flags.fullscreen = false
    end

    love.window.setMode(widthWindow, heightWindow, flags)
    widthWindow, heightWindow = love.graphics.getWidth(), love.graphics.getHeight()
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	canvas = love.graphics.newCanvas(widthWindow, heightWindow)
    ratioScale = math.min(widthWindow/widthRes, heightWindow/heightRes)
    offsetXCanvas = widthWindow/2-(widthRes/2)*ratioScale

    if heightWindow/heightRes > widthWindow/widthRes then
        camYOffset = heightWindow-heightRes*ratioScale
    else
        camYOffset = 0
    end
    preRenderCanvas = love.graphics.newCanvas(widthRes, heightRes+camYOffset)
end