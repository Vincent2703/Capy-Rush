Checkbox = class("Checkbox")

function Checkbox:init(x, y, label, state)
    self.x, self.y = x, y
    self.label = label or false
    self.state = state or false

    self.dim = 20
    self.lineWidth = 2
    self.visible = true

    if self.label then
        local currentFont = love.graphics.getFont()
        local widthText = currentFont:getWidth(self.label)
        self.xLabel, self.yLabel = self.x-widthText-10, self.y+self.lineWidth
    end

    self.offset = self.lineWidth+3
    self.dimInnerRect = self.dim-self.lineWidth*2-6
end

function Checkbox:update()
    local mouseX, mouseY = input.state.mouse.x, input.state.mouse.y
    local function checkInBounds()
        return mouseX >= self.x and mouseX <= self.x + self.dim and mouseY >= self.y and mouseY <= self.y + self.dim
    end

    if input.state.actions.newPress.click and checkInBounds() then
        self.state = not self.state
    end
end

function Checkbox:draw()
    if self.label then
        love.graphics.print(self.label, self.xLabel, self.yLabel)
    end
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.rectangle("line", self.x, self.y, self.dim, self.dim)
    if self.state then
        love.graphics.rectangle("fill", self.x+self.offset, self.y+self.offset, self.dimInnerRect, self.dimInnerRect)
    end
    love.graphics.setLineWidth(1)
end