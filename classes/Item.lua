Item = class("Item")

spriteSheetItems = love.graphics.newImage("assets/textures/items/spriteSheetItems.png")

function Item:init(name, xTexture, yTexture, callback, width, height)
    self.width = width or 16
    self.height = height or 16
    self.name = name
    self.texture = love.graphics.newQuad(xTexture, yTexture, xTexture+self.width, yTexture+self.height, spriteSheetItems)
    self.callback = callback or function() print(name) end
    self.isItem = true
end

function Item:add(x, y)
    self.x, self.y = x, y
    gameState.states["InGame"].world:add(self, x, y, self.width, self.height)
end
