GameOver = class("GameOver")

function GameOver:init()
    local function replay()
        gameState.states["InGame"].lvl:reset()
        gameState:setState("InGame", true)
    end

    local function createUI()
        local UIElements = {}

        UIElements["ReplayBtn"] = RectangleButton(
            widthRes/3,
            heightRes/2-50, 
            widthRes/3,
            50,
            true,
            "REPLAY",
            nil,
            nil,
            function() replay() end,
            "release"
        )

        UIElements["ExitBtn"] = RectangleButton(
            widthRes/3,
            heightRes/2+50, 
            widthRes/3,
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
    self.inGameCanvas = love.graphics.newCanvas(preRenderCanvas:getDimensions())
    self.inGameCanvas:renderTo(function()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(preRenderCanvas, 0, 0)
    end)
end

function GameOver:update()
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function GameOver:render()

    love.graphics.translate(offsetXCanvas, heightWindow)
    love.graphics.scale(ratioScale, -ratioScale)
    love.graphics.draw(preRenderCanvas)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, widthRes, heightRes)
    love.graphics.setColor(255, 255, 255, 1)

    love.graphics.origin()
    love.graphics.translate(offsetXCanvas, camYOffset)
    love.graphics.scale(ratioScale, ratioScale)
    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end
end