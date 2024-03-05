MessageBox = class("MessageBox")

function MessageBox:init(text, width)
    self.text = text
    self.width = width
    self.marginHeight = 20
    self.height = Utils:getTextHeight(self.text, self.width)+self.marginHeight

    self.x = math.ceil(widthWindow/2-self.width/2-0.5)
    self.y = math.ceil(heightWindow/2-self.height/2-0.5)

    self.lineWidth = 3

    self.visible = true
end

function MessageBox:update()

end

function MessageBox:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x+self.lineWidth, self.y+self.lineWidth, self.width-self.lineWidth*2, self.height-self.lineWidth*2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.text, self.x+self.lineWidth, self.y+self.lineWidth+self.marginHeight/2, self.width-self.lineWidth*2, "center")
    love.graphics.setColor(1, 1, 1)

end