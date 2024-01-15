Map = class("Map")

function Map:init(tileWidth, tileHeight, tilesetPath, predefinedChunks, nbChunksPerIter)
    self.tileWidth, self.tileHeight = tileWidth, tileHeight
    self.tilesetPath = tilesetPath
    self.predefinedChunks = predefinedChunks 
    self.nbChunksPerIter = 3
    self.mapChunks = {}

    self.startingChunkName = "street3"

    self.mapParams = {
        orientation = "orthogonal",
        width = 9,
        height = 80, --TODO
        tilewidth = tileWidth,
        tileheight = tileHeight,
        tilesets = {},
        layers = {}
    }

    local tileset = {
        name = "roads",
        firstgid = 1,
        tilewidth = tileWidth,
        tileheight = tileHeight,
        spacing = 0,
        margin = 0,
        image = tilesetPath,
        tileoffset = {x = 0, y = 0},
        tiles = {}
    }
    tileset.imagewidth, tileset.imageheight = love.graphics.newImage(tilesetPath):getDimensions()
    tileset.tilecount = math.ceil((tileset.imagewidth*tileset.imageheight)/(tileWidth*tileHeight))
    table.insert(self.mapParams.tilesets, tileset)
    self.tileset = self.mapParams.tilesets[1]

    self:addChunk(self.startingChunkName) -- Starting chunk
    --self.map = self:updateMap()

    self.mapWidth, self.mapHeight = self.map.width*tileWidth, self.map.height*tileHeight
end

function Map:addRandomChunks()
    for i=1, self.nbChunksPerIter do
        local randomValue = math.random()
        local cumulativeRatio = 0

        for chunkName, chunk in pairs(self.predefinedChunks) do
            cumulativeRatio = cumulativeRatio + chunk.ratio
            if randomValue <= cumulativeRatio then
                self:addChunk(chunkName)
                break
            end
        end
    end
end

function Map:removeOldChunks()
    if #self.mapChunks > self.nbChunksPerIter then
        for i=1, #self.mapChunks-self.nbChunksPerIter do 
            for _, obj in ipairs(self.mapChunks[i].obstacles) do
                gameState.states["InGame"].world:remove(obj)
            end
            for _, obj in ipairs(self.mapChunks[i].paths) do --Merge works ?
                gameState.states["InGame"].world:remove(obj)
            end
            table.remove(self.mapChunks, i)
        end
    end
end

function Map:manageChunks()
    self:removeOldChunks()
    self:addRandomChunks()
    --self.map = self:updateMap()
end

function Map:addChunk(chunkName)
    local chunkAsset = require("assets/maps/"..chunkName)
    local chunkMap = {
        sprites = {},
        obstacles = {},
        paths = {}
    }
    local currentHeight = 0 

    if #self.mapChunks > 0 then
        currentHeight = self.mapParams.height*self.mapParams.tileheight
        self.mapParams.height = self.mapParams.height + chunkAsset.height
    end

    for name, data in pairs(chunkAsset.layers.sprites) do
        table.insert(self.mapParams.layers,
            {
                type = "tilelayer", 
                name = name,
                x = 0,
                y = currentHeight,
                width = chunkAsset.width,
                height = chunkAsset.height,
                visible = true,
                opacity = 1,
                offsetx = 0,
                offsety = 0,
                --properties = {},
                encoding = "lua",
                data = data
            }
        )
    end

    self.map = sti(self.mapParams)
    

    
    --[[for name, data in pairs(chunkAsset.layers.sprites) do
        local spriteLayer = {
            type = "tilelayer", 
            name = name,
            x = 0,
            y = currentHeight,
            width = chunkAsset.width,
            height = chunkAsset.height,
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            --properties = {},
            encoding = "lua",
            data = data
        }
        table.insert(chunkMap.sprites, spriteLayer)
    end--]]

    for _, obs in ipairs(chunkAsset.layers.objects.obstacles) do
        local obstacle = {x=obs.x, y=obs.y+currentHeight, width=obs.width, height=obs.height, isObstacle=true}
        gameState.states["InGame"].world:add(obstacle, obstacle.x, obstacle.y, obstacle.width, obstacle.height)
        table.insert(chunkMap.obstacles, obstacle)
    end

for _, pathGroup in ipairs({chunkAsset.layers.objects.rightPaths, chunkAsset.layers.objects.leftPaths}) do
    for _, path in ipairs(pathGroup) do
        local direction = (pathGroup == chunkAsset.layers.objects.rightPaths) and "right" or "left"
        local p = {
            x = path.x,
            y = path.y + currentHeight,
            width = path.width,
            height = path.height,
            direction = direction,
            isPath = true
        }

        gameState.states["InGame"].world:add(p, p.x, p.y, p.width, p.height)
        table.insert(chunkMap.paths, p)
    end
end


    table.insert(self.mapChunks, chunkMap)
end


function Map:updateMap()
    --[[local m = {
        orientation = "orthogonal",
        width = 11,
        height = self.map.height,
        tilewidth = self.tileWidth,
        tileheight = self.tileHeight,
        tilesets = {},
        layers = {}
    }--]]

    --[[local tileset = {
        name = "roads",
        firstgid = 1,
        tilewidth = self.tileWidth,
        tileheight = self.tileHeight,
        spacing = 0,
        margin = 0,
        image = self.tilesetPath,
        tileoffset = {x = 0, y = 0},
        tiles = {}
      }--]]
    tileset.imagewidth, tileset.imageheight = self.map.tilesets[1].imagewidth, self.map.tilesets[1].imageheight
    tileset.tilecount = math.ceil((tileset.imagewidth*tileset.imageheight)/(self.tileWidth*self.tileHeight))
    table.insert(m.tilesets, tileset)

    for _, chunk in ipairs(self.mapChunks) do
        for _, spriteLayer in pairs(chunk.sprites) do
            table.insert(m.layers,
                {
                    type = "tilelayer", 
                    name = spriteLayer.name,
                    x = 0,
                    y = spriteLayer.y,
                    width = spriteLayer.width,
                    height = spriteLayer.height,
                    visible = true,
                    opacity = 1,
                    offsetx = 0,
                    offsety = 0,
                    --properties = {},
                    encoding = "lua",
                    data = spriteLayer.data
                }
            )
        end
    end

    return sti(m)
end

function Map:getNbChunkAtPos(y)
    for i, chunk in ipairs(self.mapChunks) do --TODO : Replace with queryPoint() -- MAP CHUNK PLUS UTILE
        local layer = chunk.sprites[1] -- Whatever the layer, same pos/dim
        if y >= layer.y and y <= layer.y+layer.height*self.map.tileheight then
            return i
        end
    end
end

function Map:reset()
    local world = gameState.states["InGame"].world
    local items, len = world:getItems()
    for i=1, len do
        world:remove(items[i])
    end
    self.mapChunks = {}
end