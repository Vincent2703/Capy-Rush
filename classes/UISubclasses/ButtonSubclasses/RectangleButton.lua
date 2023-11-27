RectangleButton = Button:extend("RectangleButton")

function RectangleButton:init(x, y, width, height, visible, text, colorA, colorB, callback)
    RectangleButton.super.init(self, x, y, width, height, visible, text, colorA, colorB, callback)

    self.textX, self.textY = self.x+(self.width-self.widthText)/2, self.y+self.heightText
end

function RectangleButton:update()
    if input.state.actions.click and 
       input.state.mouse.x >= self.x and input.state.mouse.x <= self.x+self.width and
       input.state.mouse.y >= self.y and input.state.mouse.y <= self.y+self.height then
        self.pressed = true
        self.callback()
    else
        self.pressed = false
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