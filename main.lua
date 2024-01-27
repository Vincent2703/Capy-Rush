function love.load()
    VERSION = 0.1
    OS = love.system.getOS()
    math.randomseed(os.time()) -- To pick different random values with math.random() at each execution
    WIDTHRES, HEIGHTRES = 432, 650 --Mettre en maj
    TILEDIM = 48

    loadLibraries()
    loadClasses()

    setSave()

    initScreen()

    local font = love.graphics.newFont("assets/fonts/FFFFORWA.ttf", 14)
    love.graphics.setFont(font)

    loadGlobalAssets() 

    gameState = GameState()
    gameState:setState("InGame", true)

    input = Input()  
end

function love.keypressed(key, scancode, isrepeat)
    if OS == "Android" and key == "escape" then
        input.phoneBackPressed = true
    end
end

function love.update(dt)
    input:update()

    gameState.currentState:update(dt)
end

function love.draw()
    love.graphics.scale(ratioScale)
    gameState.currentState:render()
end

function love.focus(f)
    if not f and gameState:isCurrentState("InGame") then
        gameState:setState("Pause", true)
    end
end

--

function loadLibraries()
    json = require("libraries/json/json")
	anim8 = require("libraries/anim8/anim8")
	class = require("libraries/30log/30log-clean")
	sti = require("libraries/sti")
    bump = require("libraries/bump/bump")
end

function loadClasses()
    require("classes/Save")

    require("classes/Map")

    require("classes/Car")
    require("classes/CarSubclasses/Player")
    require("classes/CarSubclasses/RoadUser")
    require("classes/CarSubclasses/Police")

    require("classes/Ejection")

    require("classes/Stats")
    require("classes/GUI/Notif")
    require("classes/GUI/NotifSubclasses/ShortNotif")
    require("classes/GUI/NotifSubclasses/PersistNotif")
    require("classes/GUI/Scores")
    require("classes/GUI/FuelGauge")
    require("classes/GUI/Button")
    require("classes/GUI/ButtonSubclasses/RectangleButton")
    require("classes/GUI/ButtonSubclasses/CircleButton")

    require("classes/GameState")
    require("classes/States/InGame")
    require("classes/States/Pause")
    require("classes/States/GameOver")

    require("classes/Input")
end

function loadGlobalAssets()
    globalAssets = {
        animations = {}
    }

    local imageInfo = {
        fire = { "assets/textures/effects/fireSpritesheet.png", 32, 32, 1 },
        explosion = { "assets/textures/effects/explosionSpritesheet.png", 71, 71, 2 },
        capyman = { "assets/textures/player/capymanSpritesheet.png", 48, 48, 2 }
    }

    for name, info in pairs(imageInfo) do
        local file = love.graphics.newImage(info[1])
        globalAssets.animations[name] = {
            spritesheet = file,
            grid = anim8.newGrid(info[2], info[3], file:getWidth(), file:getHeight(), 0, 0, info[4]),
            spriteWidth = info[2],
            spriteHeight = info[3]
        }
    end
end


function initScreen()
    local flags = {}
    if OS == "Android" then
        widthWindow, heightWindow = 0, 0
        flags.resizable = false
        flags.fullscreen = true
    else
        widthWindow, heightWindow = 360, 780 --936 / 780
        flags.resizable = true
        flags.fullscreen = false
    end

    love.window.setMode(widthWindow, heightWindow, flags)
    love.window.setMode(widthWindow, heightWindow, flags) --Twice fix Android gap bug

    widthWindow, heightWindow = love.graphics.getWidth(), love.graphics.getHeight()
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	canvas = love.graphics.newCanvas(widthWindow, heightWindow)
    ratioScale = math.min(widthWindow/WIDTHRES, heightWindow/HEIGHTRES)

    offsetXCamera = widthWindow-WIDTHRES*ratioScale
    if heightWindow/HEIGHTRES > widthWindow/WIDTHRES then
        offsetYMap = heightWindow-HEIGHTRES*ratioScale
    else
        offsetYMap = 0
    end

    preRenderCanvas = love.graphics.newCanvas(widthWindow, heightWindow) --Rename to game/map canvas ?
end

function setSave()
    save = Save("save.lua", false)
    local saveContent = save:read()
    local saveTable = {
        lastVersionPlayed=VERSION,
        lastTimePlayed=os.time(),
        highscore=saveContent and saveContent.highscore or 0,
        friend=saveContent and saveContent.friend or false
    }
    save:write(saveTable)
end