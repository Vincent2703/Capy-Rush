Range = class("Range")

function Range:init(x, y, min, max, defaultValue, step, label)
    self.x, self.y = x, y
    self.min, self.max  = min or 0, max or 1
    self.defaultValue = defaultValue or (self.max-self.min)/2
    self.currentValue = self.defaultValue
    self.step = (step or 1)
    self.normStep = self.step/(self.max-self.min)

    self.width = 150
    self.height = 5
    self.visible = true

    self.radiusCircle = 8
    self.xCircle = self.x+(self.defaultValue/(self.max-self.min))*self.width
    self.yCircle = self.y+self.height/2
    self.marginInBounds = 40

    self.label = label or false
    self.textX, self.textY = self.x, self.y-self.height-self.marginInBounds-self.radiusCircle
end

function Range:update()
    local mouseX, mouseY = input.state.mouse.x, input.state.mouse.y
    local function checkInBounds()
        return mouseX >= self.x-self.marginInBounds and mouseX <= self.x+self.width+self.marginInBounds and mouseY >= self.y-self.marginInBounds and mouseY <= self.y+self.height+self.marginInBounds
    end

    if input.state.actions.click and checkInBounds() then
        local posX = math.min(self.x+self.width, math.max(self.x, math.ceil(mouseX-0.5)))
        local ratio = (posX-self.x)/self.width
        local ratioStepped = math.floor(ratio/self.normStep+0.5)*self.normStep
        self.currentValue = (self.max-self.min)*ratioStepped
        self.xCircle = self.x + self.width*ratioStepped
    end
end

function Range:updateValue(value)
    self.currentValue = value
    self.xCircle = self.x + value/(self.max-self.min)*self.width
end


function Range:draw()
    love.graphics.print("Sensibility", self.textX, self.textY)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 2)
    love.graphics.circle("fill", self.xCircle, self.yCircle, self.radiusCircle)
    love.graphics.print(self.currentValue, self.x+self.width+15, self.y)
end