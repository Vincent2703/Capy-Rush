Map = class("Map")

function Map:init(tileWidth, tileHeight, tilesetPath, chunks, nbChunksPerIter)
    self.tileWidth, self.tileHeight = tileWidth, tileHeight
    self.tilesetPath = tilesetPath
    self.chunks = chunks 
    self.nbChunksPerIter = 3
    self.layers = {}

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

    table.insert(self.layers, self:createLayer("chunk1")) -- Starting chunk
    self.map = self:updateMap()

	self.mapWidth, self.mapHeight = self.map.width*tileWidth, self.map.height*tileHeight


	--[[if map.layers["Walls"] then
		for i, obj in pairs(map.layers["Walls"].objects) do
			local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
			wall:setType("static")
		end
	end--]]
end

function Map:addRandomChunksToLayers()
    for i=1, self.nbChunksPerIter do
        local randomValue = math.random()
        local cumulativeRatio = 0

        for chunkName, chunk in pairs(self.chunks) do
            cumulativeRatio = cumulativeRatio + chunk.ratio
            if randomValue <= cumulativeRatio then
                table.insert(self.layers, self:createLayer(chunkName))
                break
            end
        end
    end
end

function Map:removeOlderChunksFromLayers()
    if #self.layers > self.nbChunksPerIter then
        for i=1, #self.layers-self.nbChunksPerIter do 
            table.remove(self.layers, i)
        end
    end
end

function Map:manageMapChunks()
    self:removeOlderChunksFromLayers()
    self:addRandomChunksToLayers()
    self.map = self:updateMap()
    print(#self.layers)
end

function Map:createLayer(chunkName) 
    local chunk = require("assets/maps/"..chunkName)
    local y = 0 

    if #self.layers > 0 then
        self.map.height = self.map.height + chunk.height
        y = (self.map.height-chunk.height)*self.map.tileheight
    end
    local layer = {
        type = "tilelayer", 
        name = chunkName,
        x = 0,
        y = y,
        width = chunk.width,
        height = chunk.height,
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        properties = {},
        encoding = "lua",
        data = chunk.data
    }
    return layer
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
    tileset.imagewidth, tileset.imageheight = love.graphics.newImage(self.tilesetPath):getDimensions()
    tileset.tilecount = math.ceil((tileset.imagewidth*tileset.imageheight)/(self.tileWidth*self.tileHeight))
    table.insert(m.tilesets, tileset)

    for _, layer in ipairs(self.layers) do
        table.insert(m.layers,
        {
            type = "tilelayer", 
            name = layer.name,
            x = 0,
            y = layer.y,
            width = layer.width,
            height = layer.height,
            visible = true,
            opacity = 1,
            offsetx = 0,
            offsety = 0,
            properties = {},
            encoding = "lua",
            data = layer.data
        }
    )
    end

    return sti(m)
end