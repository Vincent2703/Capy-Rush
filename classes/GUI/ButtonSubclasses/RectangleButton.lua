RectangleButton = Button:extend("RectangleButton")

function RectangleButton:init(x, y, width, height, visible, content, colorA, colorB, background, callback, clickEvent)
    RectangleButton.super.init(self, x, y, width, height, visible, content, colorA, colorB, background, callback, clickEvent)
    if self.typeContent == "string" then
        self.textX, self.textY = self.x+(self.width-self.widthText)/2, self.y+self.heightText
    elseif self.typeContent == "Image" then
        --scale img selon width/height
    end
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
    if self.typeContent == "string" then
        love.graphics.print(self.content, self.textX, self.textY)
    elseif self.typeContent == "image" then
        love.graphics.draw(self.content, self.x, self.y)
    end
    love.graphics.setColor(255, 255, 255)
end