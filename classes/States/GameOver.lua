GameOver = class("GameOver")

function GameOver:init()
    local function replay()
        lvl:reset()
        for _, roadUser in ipairs(gameState.states["InGame"].roadUsers) do
            roadUser.collider:destroy()
        end
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
            function() print("exit") end,
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
    love.graphics.setCanvas(preRenderCanvas)
    love.graphics.clear()

    love.graphics.draw(self.inGameCanvas)
    love.graphics.translate(offsetXCanvas, heightWindow)
    love.graphics.scale(ratioScale, -ratioScale)

    love.graphics.setColor(0, 0, 0, 0.2)
    
    love.graphics.rectangle("fill", 0, 0, widthRes, heightRes)

    love.graphics.setColor(255, 255, 255, 1)

    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end

    love.graphics.setCanvas()

    love.graphics.draw(preRenderCanvas)
end