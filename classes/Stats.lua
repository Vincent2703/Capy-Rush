Stats = class("Stats")

function Stats:init()
    self.multipliers = {
        glob = 1,
        distance = 0.002,
        ejections = 5
    }

    self.achievements = {
        distance = 0,
        ejections = 0
        --ejections à la suite
        --reverseDistance
    }

    self.scores = {
        points = {
            distance = 0,
            ejections = 0
        },
        best = math.abs(save:read().highscore),
        current = 0
    }

    self.GUI = {
        scores = Scores(self.scores),
        ejections = ShortNotif("ejection", '+'..self.multipliers.ejections, {0.2, 0.55, 1}),
        reverse = PersistNotif("reverse !", "x2", {0, 0, 0}),
        onFire = PersistNotif("ON FIRE !", "x2")
    }
end

function Stats:addPoints(type, val)
    local val = val or 1
    local points = val*self.multipliers[type] * self.multipliers.glob

    self.achievements[type] = self.achievements[type] + val

    self.scores.points[type] = self.scores.points[type] + points

    self.scores.current = self.scores.current + points

    if self.GUI[type] ~= nil and self.GUI[type].className == "ShortNotif" then
        self.GUI[type].visible = true
    end
end

function Stats:save()
    local highscore = self.scores.best
    if save:read().highscore < highscore then
        local content = save:read()
        content.highscore = highscore
        save:write(content)
    end
end