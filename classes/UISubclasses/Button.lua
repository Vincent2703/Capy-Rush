Button = UI:extend("Button")

function Button:init(x, y, width, height, visible, text, colorA, colorB, callback, clickEvent)  -- TODO ? child imageBtn
    Button.super.init(self, x, y, width, height, visible, text, colorA, colorB, callback, clickEvent)
    self.text = text
    self.callback = callback or nil

    self.pressed = false
    self.colorA = colorA or {0, 0, 0}
    self.colorB = colorB or {10, 10, 10}

    local currentFont = love.graphics.getFont()
    self.widthText, self.heightText = currentFont:getWidth(text), currentFont:getHeight()

    self.event = clickEvent or "release"
end

function Button:update()
    local mouseX, mouseY = input.state.mouse.relX, input.state.mouse.relY
    local inBounds = false

    if self:instanceOf(RectangleButton) then
        inBounds = mouseX >= self.x and mouseX <= self.x + self.width and mouseY >= self.y and mouseY <= self.y + self.height
    elseif self:instanceOf(CircleButton) then
        inBounds = math.sqrt((mouseX-self.centerX)^2 + (mouseY-self.centerY)^2) <= self.radius
    end

    if self.visible then
        if input.state.actions.click and inBounds then
            self.pressed = true
            if self.event == "press" then
                self.callback()
            end
        else
            if self.event == "release" and self.pressed and inBounds then
                self.callback()
            end
            self.pressed = false
        end
    end
end