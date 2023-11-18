CircleButton = Button:extend("CircleButton")

function CircleButton:init(x, y, width, height, visible, text, colorA, colorB, callback)
    CircleButton.super.init(self, x, y, width, height, visible, text, colorA, colorB, callback)
    self.radius = math.min(self.width, self.height)/2
    self.centerX, self.centerY = x+self.radius, y+self.radius

    self.textX, self.textY = self.centerX-self.widthText/2, self.centerY-self.heightText/2
end

function CircleButton:update()
    if input.state.actions.click and 
        math.sqrt((input.state.mouse.x-self.centerX)^2 + (input.state.mouse.y-self.centerY)^2) <= self.radius then
        self.pressed = true
        if input.state.actions.newPress.click then
            self.callback()
        end
    else
        self.pressed = false
    end
end

function CircleButton:draw()
    if not self.pressed then
        love.graphics.setColor(self.colorA)
    else
        love.graphics.setColor(self.colorB)
    end
    love.graphics.circle("fill", self.centerX, self.centerY, self.radius)
    if self.pressed then
        love.graphics.setColor(self.colorA)
    else
        love.graphics.setColor(self.colorB)
    end
    love.graphics.print(self.text, self.textX, self.textY)
    love.graphics.setColor(255, 255, 255)
end