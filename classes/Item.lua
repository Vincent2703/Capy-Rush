Item = class("Item")

spriteSheetItems = ""

function Item:init(name, xTexture, yTexture, x, y, callback)
    self.name = name
    self.texture = ""
    self.x, self.y = x, y
    self.callback = callback
end