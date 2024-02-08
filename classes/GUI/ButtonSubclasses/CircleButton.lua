CircleButton = Button:extend("CircleButton")

function CircleButton:init(x, y, width, height, visible, content, colorA, colorB, background, callback, clickEvent)
    CircleButton.super.init(self,x, y, width, height, visible, content, colorA, colorB, background, callback, clickEvent)
    self.radius = math.min(self.width, self.height)/2
    self.centerX, self.centerY = x+self.radius, y+self.radius

    --if self.typeContent == "string" then
        self.textX, self.textY = self.centerX-self.widthText/2, self.centerY-self.heightText/2
    --end
end

function CircleButton:draw()
    if self.background then
        if not self.pressed then
            love.graphics.setColor(self.colorA)
        else
            love.graphics.setColor(self.colorB)
        end
        love.graphics.circle("fill", self.centerX, self.centerY, self.radius)
    end
    if self.pressed then
        love.graphics.setColor(self.colorA)
    else
        love.graphics.setColor(self.colorB)
    end
    love.graphics.print(self.content, self.textX, self.textY, 0, self.scale)
    love.graphics.setColor(255, 255, 255)
end
