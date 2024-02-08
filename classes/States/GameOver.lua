GameOver = class("GameOver")

function GameOver:init()
    local function replay()
        gameState.states["InGame"].lvl:reset()
        gameState:setState("InGame", true)
    end

    local function createUI()
        local UIElements = {}

        UIElements["ReplayBtn"] = RectangleButton(
            widthWindow/3,
            heightWindow/2-75, 
            widthWindow/3,
            50,
            true,
            "REPLAY",
            nil,
            nil,
            true,
            function() replay() end,
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
            heightWindow-50, 
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
            11,
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

function GameOver:start()
    soundManager:setMusicVolume(0.4)

    gameState.states["InGame"].stats:save()
end

function GameOver:update()
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function GameOver:render()
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