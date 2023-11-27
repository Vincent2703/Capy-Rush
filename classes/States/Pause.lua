Pause = class("Pause")

function Pause:init()
    local function createUI()
        local UIElements = {}

        UIElements["ResumeBtn"] = RectangleButton(
            widthRes/2,
            heightRes/2, 
            widthRes/3,
            50,
            true,
            "RESUME",
            nil,
            nil,
            function() gameState:setState("inGame") end
        )

        return UIElements
    end

    self.UI = createUI()
end

function Pause:start()
    self.inGameCanvas = love.graphics.newCanvas(preRenderCanvas:getDimensions())
    self.inGameCanvas:renderTo(function()
        love.graphics.setColor(255, 255, 255)
        love.graphics.draw(preRenderCanvas, 0, 0)
    end)
end

function Pause:update()
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function Pause:render()
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