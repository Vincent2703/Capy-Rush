Pause = class("Pause")

function Pause:init()
    local function createUI()
        local UIElements = {}

        UIElements["ResumeBtn"] = RectangleButton(
            widthRes/3,
            heightRes/2-25, 
            widthRes/3,
            50,
            true,
            "RESUME",
            nil,
            nil,
            function() gameState:setState("InGame") end,
            "release"
        )

        return UIElements
    end

    self.UI = createUI()
end

function Pause:start()
    self.inGameCanvas = love.graphics.newCanvas(preRenderCanvas:getDimensions())
    self.inGameCanvas:renderTo(function()
    --    love.graphics.setColor(255, 255, 255)
    love.graphics.setCanvas(self.inGameCanvas)
        love.graphics.draw(preRenderCanvas)
        love.graphics.setCanvas()
    end)
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
    love.graphics.setCanvas(preRenderCanvas)
    love.graphics.clear()

    love.graphics.draw(self.inGameCanvas, offsetXCanvas, heightRes, 0, ratioScale, -ratioScale)

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