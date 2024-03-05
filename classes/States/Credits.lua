Credits = class("Credits")

function Credits:init()
    local function createUI()
        local function navigatePanels(goTo)
            local currIdPanel = nil
            for i, panel in ipairs(self.panels) do
                if panel.current then
                    currIdPanel = i
                    break
                end
            end
        
            if currIdPanel then
                local gotoPanel = currIdPanel + goTo
                if gotoPanel > 0 and gotoPanel <= #self.panels then
                    self.panels[currIdPanel].current = false
                    self.panels[gotoPanel].current = true
        
                    self.UI.prevBtn.visible = gotoPanel > 1
                    self.UI.nextBtn.visible = gotoPanel < #self.panels
                end
            end
        end
        
        local UIElements = {}
        
        UIElements["returnBtn"] = RectangleButton(
            widthWindow-70,
            math.min(heightWindow-50, SAFEZONE.Y+SAFEZONE.H-10), --Function utils ? get min/max y...
            50,
            50,
            true,
            "return",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() gameState:setState("Home") end,
            "release"
        )

        UIElements["prevBtn"] = RectangleButton(widthWindow/2-70, math.min(heightWindow-55, SAFEZONE.Y+SAFEZONE.H), 48, 45, false, globalAssets.images.arrowLeft, {1,1,1, 1}, {1,1,1, 0.6}, false, function() navigatePanels(-1) end)
        UIElements["nextBtn"] = RectangleButton(widthWindow/2+32, math.min(heightWindow-55, SAFEZONE.Y+SAFEZONE.H), 48, 45, true, globalAssets.images.arrowRight, {1,1,1, 1}, {1,1,1, 0.6}, false, function() navigatePanels(1) end)


        UIElements["adBtn"] = RectangleButton(
            widthWindow/2-45,
            math.min(heightWindow-200, SAFEZONE.Y+SAFEZONE.H-10),
            90,
            50,
            love_admob,
            "Support me",
            {1,1,1},
            {1,1,1, 0.5},
            false,
            function() love_admob.showRewardedAd(); love_admob.requestRewardedAd(ads.ads.reward) end,
            "release"
        )   


        return UIElements
    end

    self.UI = createUI()

    self.scaleLineHeight = heightWindow/HEIGHTRES
    
    self.bgWidth = globalAssets.images.homeBackground:getWidth()
    self.zoom = widthWindow/self.bgWidth

    self.panels = {
        {render = self.canvasDev, current = true},
        {render = self.canvasArt, current = false},
        {render = self.canvasSounds, current = false},
        {render = self.canvasSpecialThanks, current = false}
    }
    self.zonePanel = {x=25, y=90, w=widthWindow-50, h=heightWindow-160}
end

function Credits:start()
    for i, panel in ipairs(self.panels) do
        if i == 1 then
            panel.current = true
        else
            panel.current = false
        end
    end
    self.UI.prevBtn.visible = false
    self.UI.nextBtn.visible = true
    
    soundManager:setMusicVolume(0.4)

    if love_admob and not love_admob.isRewardedAdLoaded() then
        love_admob.requestRewardedAd(ads.ads.reward)
    end
end

function Credits:update(dt)
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
    self.UI.adBtn.visible = love_admob and love_admob.isRewardedAdLoaded()
end

function Credits:render()
    love.graphics.scale(1/ratioScale, 1/ratioScale)
    love.graphics.origin()

    love.graphics.draw(globalAssets.images.homeBackground, 0, 0, 0, self.zoom)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
    love.graphics.setColor(1,1,1)

    love.graphics.print("Credits", 30, math.max(40, SAFEZONE.Y+5), 0, 1.4)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 20, 80, widthWindow-40, heightWindow-140, 10)
    love.graphics.setColor(1, 1, 1, 1)

    for _, panel in pairs(self.panels) do
        if panel.current then
            local font = love.graphics.getFont()
            font:setLineHeight(1.5*self.scaleLineHeight)
            panel.render(self)
            font:setLineHeight(1)
            break
        end
    end
    
    for key, ui in pairs(self.UI) do
        if ui.visible then
            ui:draw()
        end
    end

end


function Credits:canvasDev()
    local title = "Development"
    love.graphics.printf(title, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    love.graphics.printf(
    "Game's creator : Tenecifer\n"..
    "Game engine : Love2D\n\n"..
    "Library used : \n"..
    "30log by Yonaba\n"..
    "Anim8 and Bump by Kikito\n"..
    "JSON by RXI\n"..
    "STI by Landon Manning",
    self.zonePanel.x, self.zonePanel.y+Utils:getTextHeight(title, self.zonePanel.w), self.zonePanel.w)
end

function Credits:canvasArt()
    local title = "Art\n"
    love.graphics.printf(title, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    love.graphics.printf(
    "- Clouds by Artisan\n"..
    "- Cars by Kaneko\n"..
    "- Fire and explosion by BenHickling\n"..
    "- Smoke from FreePik\n"..
    "- Body of capyman by\nbluecarrot16, Evert, TheraHedwig, MuffinElZangano, Durrani, castelonia, BenCreating, ElizaWy, dalonedrau, Redshrike, Nila122, JaidynReiman, Joe White, makrohn, wulax\n"..
    "\n",
    self.zonePanel.x, self.zonePanel.y+Utils:getTextHeight(title, self.zonePanel.w), self.zonePanel.w)
end

function Credits:canvasSounds()
    local title = "Sounds\n"
    love.graphics.printf(title, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    love.graphics.printf(
    "- Musics by AudioDollar\n"..
    "- Splatter by Independent.nu\n"..
    "- Fire and obstacle collision by Jute\n"..
    "- Explosion by Michel Baradari\n"..
    "- Police siren, crash and motor from Pixabay \n"..
    "- Cheering by ParadoxMirror\n"..
    "- Car acceleration by B. Good Sounds\n"..
    "- Horns by Car Features\n"..
    "- Repair by Fronbondi_Skegs\n"..
    "- Tire burst by JustSoundSFX",
    self.zonePanel.x, self.zonePanel.y+Utils:getTextHeight(title, self.zonePanel.w), self.zonePanel.w)
end

function Credits:canvasSpecialThanks()
    local title = "Special thanks\n"
    love.graphics.printf(title, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    love.graphics.printf(
    "Inspired by 'Freeway Fury' by Serius Games\n\n"..    
    "Thanks to my partner Marion for her support and testing the game\n\n"..
    "Thanks to my sister Ludivine for testing the game\n\n"..
    "Thank YOU to play my game !\n",
    self.zonePanel.x, self.zonePanel.y+Utils:getTextHeight(title, self.zonePanel.w), self.zonePanel.w)


end