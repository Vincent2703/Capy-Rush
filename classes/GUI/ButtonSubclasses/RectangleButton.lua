RectangleButton = Button:extend("RectangleButton")

function RectangleButton:init(x, y, width, height, visible, text, colorA, colorB, background, callback, clickEvent)
    RectangleButton.super.init(self, x, y, width, height, visible, text, colorA, colorB, background, callback, clickEvent)

    self.textX, self.textY = self.x+(self.width-self.widthText)/2, self.y+self.heightText
end

function RectangleButton:draw()
    if self.background then
        if not self.pressed then
            love.graphics.setColor(self.colorA)
        else
            love.graphics.setColor(self.colorB)
        end
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
    if self.pressed then
        love.graphics.setColor(self.colorA)
    else
        love.graphics.setColor(self.colorB)
    end
    love.graphics.print(self.text, self.textX, self.textY)
    love.graphics.setColor(255, 255, 255)
end