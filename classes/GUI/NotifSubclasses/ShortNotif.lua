ShortNotif = Notif:extend("ShortNotif")

function ShortNotif:init(text, subtitle, colorText, colorBorder, size, delay)
    ShortNotif.super.init(self, text, subtitle, colorText, colorBorder, size, delay)

    self.delay = delay or 1.5
    self.time = 0
    self.distanceAnim = 50
    self.size = size or 1
    self.finished = false
end

function ShortNotif:update(dt)
    local camScreen = self.ig.camScreen
    self.textX = camScreen.x+WIDTHRES*0.15
    self.time = self.time + dt
    local timeRatio = self.time/self.delay
    self.opacity = 1-timeRatio
    self.textY = camScreen.y - timeRatio*self.distanceAnim

    if self.time >= self.delay then
        self.time = 0
        self.visible = false
        self.finished = true
    end
end

function ShortNotif:draw()
    self.textObject:set(self.text)
    love.graphics.setColor({self.colorText[1], self.colorText[2], self.colorText[3], self.opacity})
    love.graphics.draw(self.textObject, self.textX-self.borderSize,   self.textY-self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX,     self.textY-self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+self.borderSize,   self.textY-self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX-self.borderSize,   self.textY, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+self.borderSize,   self.textY, 0, self.size)
    love.graphics.draw(self.textObject, self.textX-self.borderSize,   self.textY+self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX,     self.textY+self.borderSize, 0, self.size)
    love.graphics.draw(self.textObject, self.textX+self.borderSize,   self.textY+self.borderSize, 0, self.size)
    love.graphics.setColor({self.colorBorder[1], self.colorBorder[2], self.colorBorder[3], self.opacity})
    love.graphics.draw(self.textObject, self.textX,  self.textY, 0, self.size)
    love.graphics.setColor({1, 1, 1, 1})
end