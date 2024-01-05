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
            function() gameState:setState("InGame") end,
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