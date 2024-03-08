function love.load()
    _test = false
    
    VERSION = 1.1
    OS = love.system.getOS()
    math.randomseed(os.time() .. os.clock()) -- To pick different random values with math.random() at each execution
    WIDTHRES, HEIGHTRES = 432, 650

    nbRuns = 1
    
    TILEDIM = 48

    loadLibraries()
    loadClasses()

    setSave()

    soundManager = SoundManager(
        {
            postHardcore = love.audio.newSource("assets/sounds/musics/postHardcore.ogg", "stream"),
            melodicMetal = love.audio.newSource("assets/sounds/musics/melodicMetal.ogg", "stream"),
        },
        {
            collisionObstacle = love.audio.newSource("assets/sounds/SFX/collisionObstacle.ogg", "static"),
            splatter = love.audio.newSource("assets/sounds/SFX/splatter.mp3", "static"),
            explosion = love.audio.newSource("assets/sounds/SFX/explosion.ogg", "static"),
            fire = love.audio.newSource("assets/sounds/SFX/fire.ogg", "static"),
            policeSiren = love.audio.newSource("assets/sounds/SFX/policeSiren.ogg", "static"),
            cheering = love.audio.newSource("assets/sounds/SFX/cheering.ogg", "static"),
            crash2 = love.audio.newSource("assets/sounds/SFX/crash2.ogg", "static"),
            tireScreech = love.audio.newSource("assets/sounds/SFX/tireScreech.ogg", "static"),
            vroom2 = love.audio.newSource("assets/sounds/SFX/vroom2.ogg", "static"),
            horn1 = love.audio.newSource("assets/sounds/SFX/horn1.ogg", "static"),
            horn2 = love.audio.newSource("assets/sounds/SFX/horn2.ogg", "static"),
            repair = love.audio.newSource("assets/sounds/SFX/repair.mp3", "static"),
            leak = love.audio.newSource("assets/sounds/SFX/leak.mp3", "static"),
            refuel = love.audio.newSource("assets/sounds/SFX/refuel.mp3", "static"),
            teleport = love.audio.newSource("assets/sounds/SFX/teleport.mp3", "static"),
            tireBurst = love.audio.newSource("assets/sounds/SFX/tireBurst.mp3", "static"),
            lowFuel = love.audio.newSource("assets/sounds/SFX/lowFuel.mp3", "static"),
        }
    )

    initScreen()

    local font = love.graphics.newFont("assets/fonts/FFFFORWA.ttf", 14)
    love.graphics.setFont(font)

    loadGlobalAssets() 

    input = Input()  

    gameState = GameState()
    gameState:setState("Home", true)

    if love_admob then
        adm.init(ads.ads.banner, "bottom", ads.ads.inter, true, ads.ads.reward)
	end

end


function love.keypressed(key, scancode, isrepeat)
    if OS == "Android" and key == "escape" then
        input.phoneBackPressed = true
    end
end

function love.update(dt)
    if love_admob then love_admob.update(dt) end

    input:update()

    soundManager:updateMusics()

    gameState.currentState:update(dt)
end

function love.draw()
    love.graphics.scale(ratioScale)
    gameState.currentState:render()
end

function love.focus(f)
    if not f then
        if gameState:isCurrentState("InGame") then
            gameState:setState("Pause", true)
        end
    end
end

--

function loadLibraries()
    json = require("libraries/json/json")
	anim8 = require("libraries/anim8/anim8")
	class = require("libraries/30log/30log-clean")
	sti = require("libraries/sti")
    bump = require("libraries/bump/bump")
    adm = require("libraries/adm/adm")

    if OS == "Android" then
        love_admob = require("classes/love_admob")
        ads = adMobKeys()

    end

end

function loadClasses()
    require("classes/Utils")

    require("classes/Save")

    require("classes/SoundManager")

    require("classes/Map")

    require("classes/Car")
    require("classes/CarSubclasses/Player")
    require("classes/CarSubclasses/RoadUser")
    require("classes/CarSubclasses/Police")

    require("classes/Ejection")

    require("classes/Stats")

    require("classes/Crate")

    require("classes/GUI/Notif")
    require("classes/GUI/NotifSubclasses/ShortNotif")
    require("classes/GUI/NotifSubclasses/PersistNotif")
    require("classes/GUI/Scores")
    require("classes/GUI/FuelGauge")
    require("classes/GUI/Button")
    require("classes/GUI/ButtonSubclasses/RectangleButton")
    require("classes/GUI/ButtonSubclasses/CircleButton")
    require("classes/GUI/Checkbox")
    require("classes/GUI/Range")
    require("classes/GUI/ScrollingPanel")
    require("classes/GUI/MessageBox")

    require("classes/GameState")
    require("classes/States/Home") --Rename to screens ?
    require("classes/States/InGame")
    require("classes/States/Pause")
    require("classes/States/GameOver")
    require("classes/States/Options")
    require("classes/States/Tutorial")
    require("classes/States/Credits")

    require("classes/Input")
end

function loadGlobalAssets()
    globalAssets = {
        animations = {},
        images = {
            settingsIcon = love.graphics.newImage("assets/textures/misc/settingsIcon.png"),
            homeBackground = love.graphics.newImage("assets/textures/misc/sky2.png"),
            arrowRight = love.graphics.newImage("assets/textures/misc/tuto/arrowRight.png"),
            arrowLeft = love.graphics.newImage("assets/textures/misc/tuto/arrowLeft.png"),
            lvl = love.graphics.newImage("assets/textures/misc/tuto/lvl.png"),
            fuel = love.graphics.newImage("assets/textures/misc/tuto/fuel.png"),
            signs = love.graphics.newImage("assets/textures/misc/tuto/signs.png"),

            crate = love.graphics.newImage("assets/textures/items/crate2.png")
        }
    }

    local animations = {
        fire = { "assets/textures/effects/fireSpritesheet.png", 32, 32, 1 },
        smoke = { "assets/textures/effects/smokeSpritesheet.png", 35, 35, 2 },
        explosion = { "assets/textures/effects/explosionSpritesheet.png", 71, 71, 2 },
        capyman = { "assets/textures/player/capymanSpritesheet.png", 48, 48, 2 },
        flyingCapyman = { "assets/textures/misc/flyingCapySpritesheet.png", 252, 247, 0 },
        phoneTilts = { "assets/textures/misc/tuto/tilts.png", 64, 64},
        phoneTouch = { "assets/textures/misc/tuto/touch.png", 88, 64},
        movingCar = { "assets/textures/misc/tuto/movingCar.png", 236, 150},
        ejection = { "assets/textures/misc/tuto/ejection.png", 136, 150},
    }

    for name, info in pairs(animations) do
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
        widthWindow, heightWindow = 392, 850-- 392x850 --367x850 4/3
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

    SAFEZONE = {}
    SAFEZONE.X, SAFEZONE.Y, SAFEZONE.W, SAFEZONE.H = love.window.getSafeArea()
    if OS == "Android" then --temp fix
        SAFEZONE.Y = 15
    end
end

function setSave()
    save = Save("save.lua", false)
    local saveContent = save:read()

    local music = true
    if saveContent.options and saveContent.options.music ~= nil then
        music = saveContent.options.music
    end
    local SFX = true
    if saveContent.options and saveContent.options.SFX ~= nil then
        SFX = saveContent.options.SFX
    end

    local saveTable = {
        lastVersionPlayed=VERSION,
        lastTimePlayed=os.time(),
        highscore=saveContent and saveContent.highscore or 0,
        vip=saveContent and saveContent.vip or false,
        firstTime = saveContent.firstTime == nil,
        options = {
            music = music,
            SFX = SFX,
            sensibility = saveContent.options and saveContent.options.sensibility or 1
        }
    }

    save:write(saveTable)

end

function manageMusic()
    local musics = globalAssets.sounds.musics 
    if save.content.options.music then
        if not musics.postHardcore:isPlaying() then
            love.audio.play(musics.postHardcore)
        end
    else
        if musics.postHardcore:isPlaying() then
            love.audio.pause(musics.postHardcore)
        end
    end
end

function adMobKeys()
    local ads = {}

    local ids = {
        banner = "ca-app-pub-4779033455963740/6293276100",
        inter = "ca-app-pub-4779033455963740/3332070844",
        reward = "ca-app-pub-4779033455963740/1040949421",
    }
    
    local test = {
        banner = "ca-app-pub-3940256099942544/6300978111",
        inter = "ca-app-pub-3940256099942544/1033173712",
        reward = "ca-app-pub-3940256099942544/5224354917",
    }
    
    if _test then
        ads.ads = test
    else
        ads.ads = ids
    end
    
    return ads
end