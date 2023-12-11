Stats = class("Stats")

function Stats:init()
    self.multipliers = {
        glob = 1,
        distance = 0.01,
        ejection = 10
    }

    self.achievements = {
        distSinceLastFrame = 0,
        distance = 0,
        ejections = 0
    }

    self.scores = {
        best = 999,
        current = 0
    }
end

function Stats:update()
    local achv, mult = self.achievements, self.multipliers

    achv.distance = achv.distance + achv.distSinceLastFrame
    print(achv.distSinceLastFrame)

    self.scores.current = self.scores.current + (achv.distSinceLastFrame*mult.distance + achv.ejections*mult.ejection)*mult.glob --Revoir mode de calcul car exponentiel
end