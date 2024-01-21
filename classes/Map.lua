Map = class("Map")

function Map:init(tilesetPath, predefinedChunks, nbChunksPerIter, startingChunkName)
    self.tilesetPath = tilesetPath
    self.predefinedChunks = predefinedChunks 
    self.nbChunksPerIter = nbChunksPerIter
    self.mapChunks = {}

    self.mapConfig = {
        orientation = "orthogonal",
        width = 9,
        height = self.predefinedChunks[startingChunkName].data.height,
        --tilewidth = TILEDIM,
        --tileheight = TILEDIM,
        tilesets = {},
        layers = {}
    }

    local tileset = {
        name = "roads",
        firstgid = 1,
        tilewidth = TILEDIM,
        tileheight = TILEDIM,
        spacing = 0,
        margin = 0,
        image = tilesetPath,
        tileoffset = {x = 0, y = 0},
        tiles = {}
    }
    tileset.imagewidth, tileset.imageheight = love.graphics.newImage(tilesetPath):getDimensions()
    tileset.tilecount = math.ceil((tileset.imagewidth*tileset.imageheight)/(TILEDIM*TILEDIM))
    table.insert(self.mapConfig.tilesets, tileset)

    self:addChunk(startingChunkName)
    self.map = self:updateMap()

    self.mapWidth, self.mapHeight = self.mapConfig.width*TILEDIM, self.mapConfig.height*TILEDIM
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
            for _, obj in ipairs(self.mapChunks[i].paths) do
                gameState.states["InGame"].world:remove(obj)
            end
            table.remove(self.mapChunks, i)
        end
    end
end

function Map:manageChunks()
    self:removeOldChunks()
    self:addRandomChunks()
    self.map = self:updateMap()
end

function Map:addChunk(chunkName)
    local chunkAsset = self.predefinedChunks[chunkName].data
    local chunkMap = {
        layers = {},
        obstacles = {},
        paths = {}
    }
    local currentHeight = 0 

    if #self.mapChunks > 0 then
        currentHeight = -self.mapConfig.height*TILEDIM
        self.mapConfig.height = self.mapConfig.height + chunkAsset.height 
    end
    
    --local order = {"ground", "road", "obstacles", "vegetation", "signs"}
    --for _, key in ipairs(order) do
       -- local layer = chunkAsset.layers.sprites[key]
    for name, layer in pairs(chunkAsset.layers.sprites) do
        local tileLayer = {
            name = name,
            y = currentHeight-chunkAsset.height*TILEDIM,
            width = chunkAsset.width,
            height = chunkAsset.height,
            data = layer
        }
        table.insert(chunkMap.layers, tileLayer)
    end

    for _, obs in ipairs(chunkAsset.layers.objects.obstacles) do
        local obstacle = {x=obs.x, y=currentHeight-chunkAsset.height*TILEDIM+obs.y, width=obs.w, height=obs.h, isObstacle=true}
        gameState.states["InGame"].world:add(obstacle, obstacle.x, obstacle.y, obstacle.width, obstacle.height)
        table.insert(chunkMap.obstacles, obstacle)
    end

    for _, pathGroup in ipairs({chunkAsset.layers.objects.rightPaths, chunkAsset.layers.objects.leftPaths}) do
        for _, path in ipairs(pathGroup) do
            local direction = (pathGroup == chunkAsset.layers.objects.rightPaths) and "right" or "left"
            local p = {
                x = path.x,
                y = currentHeight-path.y,
                width = path.w,
                height = path.h,
                direction = direction,
                isPath = true
            }

            gameState.states["InGame"].world:add(p, p.x, p.y, p.width, p.height)
            table.insert(chunkMap.paths, p)
        end
    end


    table.insert(self.mapChunks, chunkMap)
end


function Map:updateMap() -- To optimize. Shame that we can't directly add a layer to a map... Can we ?
    local function find(t, value)
        for i, v in ipairs(t) do
            if v == value then
                return i
            end
        end
        return nil
    end


    local m = {
        orientation = "orthogonal",
        width = self.mapConfig.width,
        height = self.mapConfig.height,
        tilewidth = TILEDIM,
        tileheight = TILEDIM,
        tilesets = {},
        layers = {}
    }

    local tileset = {
        name = "tileset",
        firstgid = 1,
        tilewidth = TILEDIM,
        tileheight = TILEDIM,
        spacing = 0,
        margin = 0,
        image = self.tilesetPath,
        tileoffset = {x = 0, y = 0},
        tiles = {}
      }
    tileset.imagewidth, tileset.imageheight = self.mapConfig.tilesets[1].imagewidth, self.mapConfig.tilesets[1].imageheight
    tileset.tilecount = math.ceil((tileset.imagewidth*tileset.imageheight)/(TILEDIM*TILEDIM))
    table.insert(m.tilesets, tileset)

    local order = {"ground", "road", "obstacles", "vegetation", "signs"}
    local orderedLayers = {}

    -- Iterate through mapChunks and sort layers based on order
    for _, chunk in ipairs(self.mapChunks) do
        for _, spriteLayer in pairs(chunk.layers) do
            local index = find(order, spriteLayer.name) -- Custom function to find index in the order table
            if index then
                table.insert(orderedLayers,
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
    end

    -- Sort the orderedLayers based on the order table
    table.sort(orderedLayers, function(a, b)
        return find(order, a.name) < find(order, b.name)
    end)

    -- Now, orderedLayers contains the layers in the desired order
    for _, layer in ipairs(orderedLayers) do
        table.insert(m.layers, layer)
    end

    

    return sti(m)
end

function Map:reset()
    local world = gameState.states["InGame"].world
    local items, len = world:getItems()
    for i=1, len do
        world:remove(items[i])
    end
    self.mapChunks = {}
end