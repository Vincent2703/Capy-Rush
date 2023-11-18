Button = UI:extend("Button")

function Button:init(x, y, width, height, visible, text, colorA, colorB, callback)  -- TODO ? child imageBtn
    Button.super.init(self, x, y, width, height, visible, text, colorA, colorB, callback)
    self.text = text
    self.callback = callback or nil

    self.pressed = false
    self.colorA = colorA or {0, 0, 0}
    self.colorB = colorB or {10, 10, 10}

    local currentFont = love.graphics.getFont()
    self.widthText, self.heightText = currentFont:getWidth(text), currentFont:getHeight()
end