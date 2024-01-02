Pause = class("Pause")

function Pause:init()
    self.inGameCanvas = love.graphics.newCanvas(widthRes, heightRes)

    local function createUI()
        local UIElements = {}

        UIElements["ResumeBtn"] = RectangleButton(
            widthRes/3,
            heightRes/2-75, 
            widthRes/3,
            50,
            true,
            "RESUME",
            nil,
            nil,
            function() gameState:setState("InGame") end,
            "release"
        )


        UIElements["ExitBtn"] = RectangleButton(
            widthRes/3,
            heightRes/2, 
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

function Pause:start()

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
    --love.graphics.clear()

    love.graphics.translate(offsetXCanvas, heightWindow)
    love.graphics.scale(ratioScale, -ratioScale)
    love.graphics.draw(preRenderCanvas)
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, widthRes, heightWindow/ratioScale)
    love.graphics.setColor(255, 255, 255, 1)

    love.graphics.origin()
    love.graphics.translate(offsetXCanvas, 0)
    love.graphics.scale(ratioScale, ratioScale)
    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end
end