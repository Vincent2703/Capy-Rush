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
            function() replay() end,
            "release"
        )

        UIElements["ExitBtn"] = RectangleButton(
            widthWindow/3,
            heightWindow/2+25, 
            widthWindow/3,
            50,
            true,
            "EXIT",
            nil,
            nil,
            function() love.event.quit(0) end,
            "release"
        )

        return UIElements
    end

    self.UI = createUI()
end

function GameOver:start()
    --[[self.inGameCanvas = love.graphics.newCanvas(preRenderCanvas:getDimensions())
    self.inGameCanvas:renderTo(function()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(preRenderCanvas, 0, 0)
    end)--]]
end

function GameOver:update()
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function GameOver:render()
    love.graphics.translate(0, heightRes+offsetYMap/ratioScale) --Temporaire, trouver une meilleure méthode
    love.graphics.scale(1/ratioScale, -1/ratioScale)
    love.graphics.draw(preRenderCanvas) 
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
    love.graphics.setColor(255, 255, 255, 1)

    love.graphics.origin()

    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end
end