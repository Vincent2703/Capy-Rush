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
    }

    self.scores = {
        points = {
            distance = 0,
            ejections = 0
        },
        best = save:read().highscore,
        current = 0
    }
end

function Stats:addPoints(type, val)
    local val = val or 1
    local points = val*self.multipliers[type] * self.multipliers.glob

    self.achievements[type] = self.achievements[type] + val

    self.scores.points[type] = self.scores.points[type] + points

    self.scores.current = self.scores.current + points
end

function Stats:save()
    local highscore = self.scores.best
    if save:read().highscore < highscore then
        local content = save:read()
        content.highscore = highscore
        save:write(content)
    end
end