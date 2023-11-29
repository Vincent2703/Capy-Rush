RectangleButton = Button:extend("RectangleButton")

function RectangleButton:init(x, y, width, height, visible, text, colorA, colorB, callback, clickEvent)
    RectangleButton.super.init(self, x, y, width, height, visible, text, colorA, colorB, callback, clickEvent)

    self.textX, self.textY = self.x+(self.width-self.widthText)/2, self.y+self.heightText
    self.event = clickEvent or "press"
end

function RectangleButton:update()
    local mouseX, mouseY = input.state.mouse.x, input.state.mouse.y
    local inBounds = mouseX >= self.x and mouseX <= self.x + self.width and mouseY >= self.y and mouseY <= self.y + self.height

    if self.visible then
        if input.state.actions.click and inBounds then
            self.pressed = true
            if self.event == "press" then
                self.callback()
            end
        else
            if self.event == "release" and self.pressed and inBounds then
                self.callback()
            end
            self.pressed = false
        end
    end
end

function RectangleButton:draw()
    if not self.pressed then
        love.graphics.setColor(self.colorA)
    else
        love.graphics.setColor(self.colorB)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    if self.pressed then
        love.graphics.setColor(self.colorA)
    else
        love.graphics.setColor(self.colorB)
    end
    love.graphics.print(self.text, self.textX, self.textY)
    love.graphics.setColor(255, 255, 255)
end