Crate = class("Crate")

function Crate:init(x, y)
    self.x, self.y = x, y
    self.sprite = globalAssets.images.crate
    self.spriteWidth, self.spriteHeight = self.sprite:getWidth(), self.sprite:getHeight()

    gameState.states["InGame"].world:add(self, self.x, self.y, self.spriteWidth, self.spriteHeight) 

    self.active = true
end

function Crate:update(dt)
    local inGame = gameState.states["InGame"]
    local world = inGame.world
    local filterPlayer = function(item)
        return item.className == "Player"
    end

    local _, lenPlayer = world:queryRect(self.x, self.y, self.spriteWidth, self.spriteHeight, filterPlayer)
    local collision = lenPlayer == 1 

    if collision and self.active then
        self:openCrate()
    end
end

function Crate:draw()
    love.graphics.draw(self.sprite, self.x+math.ceil(self.spriteWidth/2), math.ceil(self.y+self.spriteHeight/2), 0, 0.5)
end


function Crate:openCrate()
    local inGame = gameState.states["InGame"]
    local items = inGame.items

    local result = false
    repeat
        local randItem = Utils:weightedRandom(items)

        result = randItem and randItem.fn() or false

    until(result)
    self.active = false
end