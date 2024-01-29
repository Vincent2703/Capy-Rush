Button = class("Button")

function Button:init(x, y, width, height, visible, content, colorA, colorB, background, callback, clickEvent)
    self.x, self.y = x, y
    self.width, self.height = width, height
    self.visible = visible or false
    self.typeContent = nil
    if type(content) == "string" then
        self.typeContent = "string"
    elseif type(content) == "userdata" and content:typeOf("Image") then
        self.typeContent = "image"
    end
    self.content = content
    self.callback = callback or function() end

    self.pressed = false
    self.colorA = colorA or {0, 0, 0}
    self.colorB = colorB or {10, 10, 10}
    self.background = background

    if self.typeContent == "string" then
        local currentFont = love.graphics.getFont()
        self.widthText, self.heightText = currentFont:getWidth(content), currentFont:getHeight()
    end

    self.event = clickEvent or "release"
end

function Button:update()
    local mouseX, mouseY = input.state.mouse.x, input.state.mouse.y

    local function checkInBounds()
        if self:instanceOf(RectangleButton) then
            return mouseX >= self.x and mouseX <= self.x + self.width and mouseY >= self.y and mouseY <= self.y + self.height
        elseif self:instanceOf(CircleButton) then
            return math.sqrt((mouseX-self.centerX)^2 + (mouseY-self.centerY)^2) <= self.radius
        end
    end

    if self.visible then
        if input.state.actions.click and checkInBounds() then
            self.pressed = true
            if self.event == "press" then
                self.callback()
            end
        else
            if self.event == "release" and self.pressed and checkInBounds() then
                self.callback()
            end
            self.pressed = false
        end
    end
end