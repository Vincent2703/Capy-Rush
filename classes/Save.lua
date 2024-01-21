Save = class("Save")

function Save:init(filename, encryption)
    self.filename = filename
    self.encryption = encryption or false
end

function Save:write(data)
    local data = json.encode(data)
    if self.encryption then
        local compressedData = love.data.compress("string", "lz4", data, 9)
        data = love.data.encode("string", "base64", compressedData)
    end
    local file = love.filesystem.newFile(self.filename, 'w')
    file:write(data)
    file:close()
end

function Save:read()
    local file = love.filesystem.newFile(self.filename, 'r')
    if file == nil then
        return nil
    end
    local data = file:read()
    file:close()

    if self.encryption then -- Should check if b64 instead
        local decoded = love.data.decode("string", "base64", data)
        data = love.data.decompress("string", "lz4", decoded)
    end
    data = json.decode(data)

    return data
end