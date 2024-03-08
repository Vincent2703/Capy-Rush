MessageBox = class("MessageBox")

function MessageBox:init(text, width, callback, borderColor, bgColor, txtColor)
    self.text = text
    self.width = width
    self.borderColor = borderColor or {0, 0, 0}
    self.bgColor = bgColor or {0, 0, 0, 0.4}
    self.txtColor = txtColor or {1, 1, 1, 1}
    self.callback = callback or false
    self.marginTop = 30
    self.marginBottom = 70
    self.lineHeightVal = 1.1*heightWindow/HEIGHTRES
    self.height = Utils:getTextHeight(self.text, self.width, self.lineHeightVal)+self.marginTop+self.marginBottom

    self.x = math.ceil(widthWindow/2-self.width/2-0.5)
    self.y = math.ceil(heightWindow/2-self.height/2-0.5)

    self.lineWidth = 3

    self.visible = false

    local textBtn = "CLOSE"
    local txtWidth = love.graphics.getFont():getWidth(textBtn)
    self.closeBtn = RectangleButton(math.ceil(self.x+self.width/2-txtWidth/2-0.5), self.y+self.height-50, txtWidth, 50, true, textBtn, false, false, false, 
        function() 
            self.visible = false 
            if self.callback then
                self.callback()
            end
        end
    )
end

function MessageBox:update()
    self.closeBtn:update()
end

function MessageBox:draw()
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(self.bgColor)
    local halfLineWidth = math.ceil(self.lineWidth/2)
    love.graphics.rectangle("fill", self.x+halfLineWidth, self.y+halfLineWidth, self.width-self.lineWidth, self.height-self.lineWidth)
    love.graphics.setColor(self.txtColor)
    local font = love.graphics.getFont()
    font:setLineHeight(self.lineHeightVal)
    love.graphics.printf(self.text, self.x+halfLineWidth, self.y+halfLineWidth+self.marginTop, self.width-self.lineWidth, "center")
    font:setLineHeight(1)
    love.graphics.setColor(1, 1, 1)
    self.closeBtn:draw()
end