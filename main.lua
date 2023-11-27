function love.load()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    widthRes, heightRes = 352, 626
    widthWindow, heightWindow = 352, 626

    loadLibraries()
    loadClasses()

    initScreen()

    local font = love.graphics.newFont("assets/fonts/FFFFORWA.ttf", 14)
    love.graphics.setFont(font)

    gameState = GameState()
    gameState:setState("inGame")
    --for _, state in pairs(gameState.states) do
    --    state:start()
    --end
    gameState.currentState:start()

    input = Input()  
end

function love.update(dt)
    input:update()

    if input.state.actions.newPress.eject then
        --print(lvl:getLayerAtPos(player.y))
    end

    if gameState:isCurrentState("InGame") and input.state.actions.newPress.pause then  --Move to GameState
		gameState:setState("pause")
        gameState.currentState:start()
    elseif gameState:isCurrentState("Pause") and input.state.actions.newPress.pause then
        gameState:setState("inGame")
    end

    gameState.currentState:update(dt)

end

function love.draw()
    gameState.currentState:render()
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

    require("classes/GameState")
    require("classes/States/InGame")
    require("classes/States/Pause")

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