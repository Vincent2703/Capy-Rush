Pause = class("Pause")

function Pause:init()
    local function createUI()
        local UIElements = {}

        UIElements["ResumeBtn"] = RectangleButton(
            widthWindow/3,
            heightWindow/2-75, 
            widthWindow/3,
            50,
            true,
            "RESUME",
            nil,
            nil,
            true,
            function() gameState:setState("InGame") end,
            "release"
        )


        UIElements["HomeBtn"] = RectangleButton(
            widthWindow/3,
            heightWindow/2+25, 
            widthWindow/3,
            50,
            true,
            "HOME",
            nil,
            nil,
            true,
            function() gameState.states["InGame"].stats:save();gameState:setState("Home") end,
            "release"
        )

        
        UIElements["ExitBtn"] = RectangleButton(
            widthWindow-60,
            math.min(heightWindow-50, SAFEZONE.Y+SAFEZONE.H), 
            50,
            50,
            true,
            "EXIT",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState.states["InGame"].stats:save();love.event.quit(0) end,
            "release"
        )

        
        UIElements.settingsBtn = RectangleButton(
            widthWindow-50,
            11+SAFEZONE.Y,
            50,
            50,
            true,
            globalAssets.images.settingsIcon,
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState:setState("Options", true) end
        )


        return UIElements
    end

    self.UI = createUI()
end

function Pause:start()
    soundManager:setMusicVolume(0.4)
end

function Pause:update()
    if input.state.actions.newPress.pause then
        gameState:setState("InGame")
    end

    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function Pause:render()
    love.graphics.scale(1/ratioScale, 1/ratioScale)
    love.graphics.draw(preRenderCanvas) 
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.origin()

    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end
end