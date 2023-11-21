Map = class("Map")

function Map:init(tileWidth, tileHeight, tilesetPath, predefinedChunks, nbChunksPerIter)
    self.tileWidth, self.tileHeight = tileWidth, tileHeight
    self.tilesetPath = tilesetPath
    self.predefinedChunks = predefinedChunks 
    self.nbChunksPerIter = 3
    self.mapChunks = {}

    self.map = {
        orientation = "orthogonal",
        width = 11,
        height = 50,
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
    table.insert(self.map.tilesets, tileset)

    self:addChunk("chunk1") -- Starting chunk
    self.map = self:updateMap()

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
            table.remove(self.mapChunks, i)
        end
        -- Need to remove the old colliders
    end
end

function Map:manageChunks()
    self:removeOldChunks()
    self:addRandomChunks()
    self.map = self:updateMap()
end

function Map:addChunk(chunkName)
    local chunkAsset = require("assets/maps/"..chunkName)
    local chunkMap = {
        sprites = {},
        obstacles = {},
        paths = {}
    }
    local y = 0 

    if #self.mapChunks > 0 then
        self.map.height = self.map.height + chunkAsset.height
        y = (self.map.height-chunkAsset.height)*self.map.tileheight
    end
    
    for _, data in pairs(chunkAsset.layers.sprites) do
        local spriteLayer = {
            type = "tilelayer", 
            name = chunkName,
            x = 0,
            y = y,
            width = chunkAsset.width,
            height = chunkAsset.height,
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            properties = {},
            encoding = "lua",
            data = data
        }
        table.insert(chunkMap.sprites, spriteLayer)
    end

    for _, obs in ipairs(chunkAsset.layers.objects.obstacles) do
        table.insert(chunkMap.obstacles, obs)
        local wall = world:newRectangleCollider(obs.x, obs.y+y, obs.width, obs.height) -- A modif
        wall:setType("static")
    end

    for _, path in ipairs(chunkAsset.layers.objects.paths) do
        path.y = path.y + y
        table.insert(chunkMap.paths, path)
    end

    table.insert(self.mapChunks, chunkMap)
end


function Map:updateMap()
    local m = {
        orientation = "orthogonal",
        width = 11,
        height = self.map.height,
        tilewidth = self.tileWidth,
        tileheight = self.tileHeight,
        tilesets = {},
        layers = {}
    }

    local tileset = {
        name = "roads",
        firstgid = 1,
        tilewidth = self.tileWidth,
        tileheight = self.tileHeight,
        spacing = 0,
        margin = 0,
        image = self.tilesetPath,
        tileoffset = {x = 0, y = 0},
        tiles = {}
      }
    tileset.imagewidth, tileset.imageheight = love.graphics.newImage(self.tilesetPath):getDimensions() -- Definir ça une fois dans l'init
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
                    properties = {},
                    encoding = "lua",
                    data = spriteLayer.data
                }
            )
        end
    end

    return sti(m)
end