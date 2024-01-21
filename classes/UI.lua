UI = class("UI")

function UI:init(x, y, width, height, visible)
    self.x, self.y = x, y
    self.width, self.height = width, height
    self.visible = visible or false

    --self.canvas = love.graphics.newCanvas(self.width, self.height)
end

function UI:toggleVisibility()
    self.visible = not self.visible
end