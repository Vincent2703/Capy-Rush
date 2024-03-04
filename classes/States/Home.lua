Home = class("Home")

function Home:init()
    self.canPlay = input.config.accelerometer or OS ~= "Android"

    self.flyingCapyAnim = anim8.newAnimation(globalAssets.animations.flyingCapyman.grid("1-6", 1), 0.1)
    self.scrollSpeed = 400
    self.offsetY = 0
    self.offsetYb = 0
    self.bgWidth = globalAssets.images.homeBackground:getWidth()
    self.bgHeight = globalAssets.images.homeBackground:getHeight()
    self.zoom = widthWindow/self.bgWidth
    self.startOffsetY = heightWindow-self.bgHeight*self.zoom

    self.floatAmplitude = 15  -- Amplitude of floating motion
    self.floatFrequency = 2    -- Frequency of floating motion (higher frequency = faster motion)
    self.floatOffset = 0       -- Initial offset for floating motion

    local function createUI()
        local UIElements = {}

        UIElements.playBtn = RectangleButton(
            math.ceil(widthWindow/3 + 5),
            math.ceil(heightWindow/2+100), 
            math.ceil(widthWindow/3.3),
            50,
            self.canPlay,
            "PLAY",
            nil,
            nil,
            false,
            function() gameState:setState("InGame", true) end,
            "release",
            true
        )

        UIElements.settingsBtn = RectangleButton(
            widthWindow-110,
            SAFEZONE.Y+11,
            50,
            50,
            true,
            globalAssets.images.settingsIcon,
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState:setState("Options", true) end
        )

        UIElements.exitBtn = RectangleButton(
            widthWindow-60,
            SAFEZONE.Y,
            50,
            50,
            true,
            "exit",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() love.event.quit(0) end
        )

        UIElements.tutoBtn = RectangleButton(
            30,
            math.min(heightWindow-50, SAFEZONE.Y+SAFEZONE.H-10),
            100,
            50,
            true,
            "How to play?",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState:setState("Tutorial", true) end
        )


        UIElements.credits = RectangleButton(
            widthWindow-85,
            math.min(heightWindow-50, SAFEZONE.Y+SAFEZONE.H-10),
            60,
            50,
            true,
            "Credits",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState:setState("Credits", true) end
        )


        return UIElements
    end

    self.UI = createUI()
end

function Home:start()
    self.canPlay = input.config.accelerometer or OS ~= "Android"
    soundManager:setMusicVolume(0.4)
end

function Home:update(dt)
    self.flyingCapyAnim:update(dt)

    self.offsetY = self.offsetY + self.scrollSpeed * dt

    if self.offsetY > self.bgHeight*self.zoom then
        self.offsetY = 0
    end

    self.floatOffset = self.floatOffset + dt * self.floatFrequency
    self.floatingValue = math.sin(self.floatOffset) * self.floatAmplitude


    for _, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function Home:render()
    love.graphics.scale(1/ratioScale, 1/ratioScale)

    love.graphics.draw(globalAssets.images.homeBackground, 0, math.ceil(self.startOffsetY + self.offsetY -0.5), 0, self.zoom) 
    love.graphics.draw(globalAssets.images.homeBackground, 0, math.ceil(self.startOffsetY + self.offsetY - self.bgHeight*self.zoom - 0.5), 0, self.zoom)
    
    local flyingCapyman = globalAssets.animations.flyingCapyman
    self.flyingCapyAnim:draw(flyingCapyman.spritesheet, widthWindow/2-flyingCapyman.spriteWidth/2, flyingCapyman.spriteHeight + self.floatingValue)
    for _, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end

    local title = "Capy Dash"
    Utils:printCtrTxtWScl(title, 130, 2)

    if self.canPlay then
        if save.content.highscore > 0 then
            Utils:printCtrTxtWScl("Highscore : "..save.content.highscore, heightWindow/2+250)
        end
    else
        love.graphics.setColor(0.6, 0, 0)
        love.graphics.printf("Sorry...\n\n Your device does not have any accelerometer. \n They are required to play to the game...", 5, heightWindow/2+150, widthWindow-10, "center")
        love.graphics.setColor(1, 1, 1)
    end

end
