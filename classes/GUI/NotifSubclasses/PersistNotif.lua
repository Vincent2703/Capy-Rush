PersistNotif = Notif:extend("PersistNotif")

function PersistNotif:init(text, subtitle, colorText, colorBorder, size, type)
    PersistNotif.super.init(self, text, subtitle, colorText, colorBorder, size, type)

    self.type = type or "shaking"
    self.amplitude = 2
end

function PersistNotif:update(dt)
    local camScreen = self.ig.camScreen
    self.textX = camScreen.x+WIDTHRES*0.15
    self.textY = camScreen.y 
end

function PersistNotif:draw()
    local offsetX = self.type=="shaking" and math.random(-self.amplitude, self.amplitude) or 0
    local offsetY = self.type=="shaking" and math.random(-self.amplitude, self.amplitude) or 0

    self.textObject:set(self.text)
    love.graphics.setColor({self.colorText[1], self.colorText[2], self.colorText[3], self.opacity})
    love.graphics.draw(self.textObject, self.textX+offsetX-self.borderSize,   self.textY+offsetY-self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+offsetX,     self.textY+offsetY-self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+offsetX+self.borderSize,   self.textY+offsetY-self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+offsetX-self.borderSize,   self.textY+offsetY, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+offsetX+self.borderSize,   self.textY+offsetY, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+offsetX-self.borderSize,   self.textY+offsetY+self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+offsetX,     self.textY+offsetY+self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+offsetX+self.borderSize,   self.textY+offsetY+self.borderSize, 0, self.size)
    love.graphics.setColor({self.colorBorder[1], self.colorBorder[2], self.colorBorder[3], self.opacity})
    love.graphics.draw(self.textObject, self.textX+offsetX,  self.textY+offsetY, 0, self.size)
    love.graphics.setColor({1, 1, 1, 1})
end