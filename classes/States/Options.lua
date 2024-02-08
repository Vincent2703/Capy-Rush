Options = class("Options")

function Options:init()
    local function createUI()
        local UIElements = {}
        UIElements["musicCBX"] = Checkbox(
            200,
            200,
            "Music"
        )
        UIElements["SFXCBX"] = Checkbox(
            200,
            250,
            "SFX"
        )
        UIElements["sensibilityRange"] = Range(
            120,
            350,
            0,
            2,
            nil,
            0.1,
            "Sensibility"
        )
        UIElements["saveBtnRtGame"] = RectangleButton(
            125,
            450, 
            150,
            50,
            false,
            "Save & Resume",
            nil,
            nil,
            true,
            function() self:saveOptions(); gameState:setState("InGame") end,
            "release"
        )
        UIElements["saveBtnRtHome"] = RectangleButton(
            125,
            450, 
            150,
            50,
            false,
            "Save & Return",
            nil,
            nil,
            true,
            function() self:saveOptions(); gameState:setState("Home") end,
            "release"
        )

        return UIElements
    end

    self.UI = createUI()

    self.bgWidth = globalAssets.images.homeBackground:getWidth()
    self.zoom = widthWindow/self.bgWidth
end

function Options:start()
    if gameState.prevState == "Home" then
        self.UI.saveBtnRtHome.visible = true
        self.UI.saveBtnRtGame.visible = false
    else
        self.UI.saveBtnRtHome.visible = false
        self.UI.saveBtnRtGame.visible = true
    end

    soundManager:setMusicVolume(0.4)

    local optionsSaved = save:read().options

    self.UI.musicCBX.state = optionsSaved.music
    self.UI.SFXCBX.state = optionsSaved.SFX
    self.UI.sensibilityRange:updateValue(optionsSaved.sensibility)
end

function Options:saveOptions()
    input.state.accelerometer.tiltXSensibility = self.UI.sensibilityRange.currentValue
    if not self.UI.musicCBX.state then
        soundManager:pauseMusic()
    else
        soundManager:resumeMusic()
    end
    
    local options = {
        music = self.UI.musicCBX.state,
        SFX = self.UI.SFXCBX.state,
        sensibility = self.UI.sensibilityRange.currentValue
    }
    local content = save:read()
    content.options = options

    save:write(content)
end

function Options:update()
    if input.state.actions.newPress.Options then
        gameState:setState("InGame")
    end

    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function Options:render()
    love.graphics.scale(1/ratioScale, 1/ratioScale)
    love.graphics.origin()

    if gameState.prevState == "InGame" then
        love.graphics.draw(preRenderCanvas) 
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
        love.graphics.setColor(1, 1, 1, 1)
    else
        love.graphics.draw(globalAssets.images.homeBackground, 0, 0, 0, self.zoom)
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
        love.graphics.setColor(1,1,1)
    end

    love.graphics.print("Options", 30, 30, 0, 1.4) --Element Title

    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end
end