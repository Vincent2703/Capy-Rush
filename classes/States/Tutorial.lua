Tutorial = class("Tutorial")

function Tutorial:init()
    local function createUI()
        local UIElements = {}
        
        UIElements["returnBtn"] = RectangleButton(
            widthWindow-60,
            heightWindow-50, 
            50,
            50,
            true,
            "return",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState:setState("Home") end,
            "release"
        )

        UIElements["tutoScrlPnl"] = ScrollingPanel()

        return UIElements
    end

    self.UI = createUI()
    
    self.bgWidth = globalAssets.images.homeBackground:getWidth()
    self.zoom = widthWindow/self.bgWidth
end

function Tutorial:start()
    soundManager:setMusicVolume(0.4)
end

function Tutorial:update()
    if input.state.actions.newPress.pause then
        gameState:setState("InGame")
    end

    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function Tutorial:render()
    love.graphics.scale(1/ratioScale, 1/ratioScale)
    love.graphics.origin()

    love.graphics.draw(globalAssets.images.homeBackground, 0, 0, 0, self.zoom)
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
    love.graphics.setColor(1,1,1)

    love.graphics.print("Tutorial", 30, 30, 0, 1.4) --Element Title

    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end
end