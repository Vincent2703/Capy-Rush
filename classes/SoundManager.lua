SoundManager = class("SoundManager")

function SoundManager:init(musics, sfx)
    self.musics = musics or {}
    self.sfx = sfx or {}

    self.currentMusic = nil

    self.attenuation = {min=5, max=120}
    love.audio.setDopplerScale(2)
    love.audio.setDistanceModel("linearclamped")
end

function SoundManager:playMusic(title)
    self.currentMusic = title

    local music = self.musics[title]

    if self.currentMusic ~= nil then
        self.musics[self.currentMusic]:stop()
    end

    if music and save.content.options.music then
        music:setRelative(true)
        music:play()
    end
end

function SoundManager:updateMusics()
    if self.currentMusic == nil then
        local firstTitle = "postHardcore"
        self:playMusic(firstTitle)
    elseif not self.musics[self.currentMusic]:isPlaying() then
        local function getNextMusicTitle(inputKey)
            local keys = {}
            for k, _ in pairs(self.musics) do
                table.insert(keys, k)
            end
        
            table.sort(keys)
        
            local index = 1
            for i, key in ipairs(keys) do
                if key == inputKey then
                    index = i
                    break
                end
            end
        
            local nextIndex = (index % #keys) + 1
            return keys[nextIndex]
        end

        self:playMusic(getNextMusicTitle(self.currentMusic))
    end
end

function SoundManager:pauseMusic()
    self.musics[self.currentMusic]:pause()
end

function SoundManager:resumeMusic()
    self.musics[self.currentMusic]:setRelative(true)
    self.musics[self.currentMusic]:play()
end

function SoundManager:setMusicVolume(vol)
    self.musics[self.currentMusic]:setVolume(vol)
end

function SoundManager:playSFX(name, loop, posX, posY, attMin, attMax)
    if save.content.options.SFX then
        local sfx = self.sfx[name]:clone() --Better than new source

        sfx:setLooping(loop or false)
        local relative = not (posX and posY)
        sfx:setRelative(relative)

        if not relative then
            attMin = attMin or self.attenuation.min
            attMax = attMax or self.attenuation.max
            sfx:setAttenuationDistances(attMin, attMax)
            sfx:setPosition(posX, posY)
        end
        sfx:play()

        return sfx
    end
end