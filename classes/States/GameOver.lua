GameOver = class("GameOver")

function GameOver:init()
    local function replay()
        gameState.states["InGame"].lvl:reset()
        gameState:setState("InGame", true)
    end

    local function createUI()
        local UIElements = {}

        UIElements["ReplayBtn"] = RectangleButton(
            widthWindow/3,
            heightWindow/2-75, 
            widthWindow/3,
            50,
            true,
            "REPLAY",
            nil,
            nil,
            true,
            function() --TEMP
                if love_admob and nbRuns>1 and nbRuns%4 == 0 then
                    local result = love_admob.isInterstitialLoaded()
                    if result then
                        love_admob.showInterstitial()
                    else
                        replay()
                    end
                else
                    replay() 
                end
                nbRuns = nbRuns+1
            end,
            "release"
        )

        UIElements["HomeBtn"] = RectangleButton(
            widthWindow/3,
            heightWindow/2+25, 
            widthWindow/3,
            50,
            true,
            "HOME",
            nil,
            nil,
            true,
            function() gameState.states["InGame"].stats:save();gameState:setState("Home") end,
            "release"
        )

        UIElements["ExitBtn"] = RectangleButton(
            widthWindow-60,
            math.min(heightWindow-50, SAFEZONE.Y+SAFEZONE.H-10), 
            50,
            50,
            true,
            "EXIT",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState.states["InGame"].stats:save();love.event.quit(0) end,
            "release"
        )

        UIElements.settingsBtn = RectangleButton(
            widthWindow-50,
            math.max(11, SAFEZONE.Y),
            50,
            50,
            true,
            globalAssets.images.settingsIcon,
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState:setState("Options", true) end
        )

        return UIElements
    end

    self.UI = createUI()
end

function GameOver:start()
    local stats = gameState.states["InGame"].stats

    soundManager:setMusicVolume(0.4)

    self.highscore = stats.GUI.scores.beatingHighscore
    stats:save()
end

function GameOver:update()
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function GameOver:render()
    local stats = gameState.states["InGame"].stats

    love.graphics.scale(1/ratioScale, 1/ratioScale)
    love.graphics.draw(preRenderCanvas) 
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.origin()

    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end

    local gameOverTxt = "Game Over !"
    local txtHeight = Utils:getTextHeight("gameOverTxt", widthWindow)
    local yPos = math.ceil(heightWindow/5)
    Utils:printCtrTxtWScl(gameOverTxt, yPos, 1.5)
    if self.highscore then
        love.graphics.printf("You beat your highscore !", 0, txtHeight+yPos+20, widthWindow, "center")
        love.graphics.printf("New highscore: "..math.abs(stats.scores.best), 0, txtHeight*2+yPos+20, widthWindow, "center")
    else
        love.graphics.printf("Your score: "..math.abs(math.ceil(stats.scores.current-0.5)).."\n\nHighscore: "..math.abs(stats.scores.best), 0, txtHeight+yPos+20, widthWindow, "center")
    end
end