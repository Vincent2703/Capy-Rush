NotifScore = UI:extend("NotifScore")

function NotifScore:init(x, y, width, height, visible, text, score)
    NotifScore.super.init(self, x, y, width, height, visible, text, score)
    self.text = text
    self.score = "+ "..score

    self.textObject = love.graphics.newText(love.graphics.getFont(), text)
    self.borderSize = 3 
end

function NotifScore:update()

end

function NotifScore:draw()
    self.textObject:set(self.text)
    love.graphics.setColor({255, 0, 0})
    love.graphics.draw(self.textObject, self.x-self.borderSize,   self.y-self.borderSize)
    love.graphics.draw(self.textObject, self.x,     self.y-self.borderSize)
    love.graphics.draw(self.textObject, self.x+self.borderSize,   self.y-self.borderSize)
    love.graphics.draw(self.textObject, self.x-self.borderSize,   self.y)
    love.graphics.draw(self.textObject, self.x+self.borderSize,   self.y)
    love.graphics.draw(self.textObject, self.x-self.borderSize,   self.y+self.borderSize)
    love.graphics.draw(self.textObject, self.x,     self.y+self.borderSize)
    love.graphics.draw(self.textObject, self.x+self.borderSize,   self.y+self.borderSize)
    love.graphics.setColor({255, 255, 255})
    love.graphics.draw(self.textObject, self.x,  self.y)
    love.graphics.setColor({255, 255, 255})
end