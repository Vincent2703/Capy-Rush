Scores = class("Scores")

function Scores:init(scores)
    self.scores = scores

    self.current, self.highscore = 0, math.abs(save:read().highscore)

    self.time = 0
    self.beatingHighscore = false
    self.canPlayCheering = self.highscore > 10
    self.blink = true --true = visible
    self.blinkTime = 1
    self.currentFont = love.graphics.getFont()
    self.yText = self.currentFont:getHeight()

    self.visible = true
end

function Scores:update(dt)
    self.current = math.abs(math.ceil(self.scores.current - 0.5))
    self.beatingHighscore = self.current > self.highscore

    if self.beatingHighscore then
        if self.canPlayCheering then
            soundManager:playSFX("cheering") --InGame instead ?
            self.canPlayCheering = false
        end
        self.time = self.time + dt

        if self.time <= self.blinkTime then
            self.blink = true --visible
        elseif self.time > self.blinkTime and self.time < 2*self.blinkTime then
            self.blink = false --not visible
        else
            self.time = 0
        end
    end
end

function Scores:draw()
    local widthText, heightText = self.currentFont:getWidth(self.current), self.yText

    --LVL
    local x, y = 20, math.max(SAFEZONE.Y+5, math.floor(heightWindow*0.05 - heightText/2))
    love.graphics.print("LVL: "..gameState.states["InGame"].difficulty.id, 20, y)

    x = math.floor(widthWindow/2 - widthText/2)
    love.graphics.print(self.current, x, y, 0, 1.2)

    if self.beatingHighscore and not self.blink then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("highscore !", x+widthText+10, y, 0, 0.5)
        love.graphics.setColor(1, 1, 1)
    elseif not self.beatingHighscore then
        love.graphics.print(self.highscore,  x+widthText+10, y, 0, 0.5)
    end
end