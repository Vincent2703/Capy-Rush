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
            widthWindow-60,
            math.min(heightWindow-50, SAFEZONE.Y+SAFEZONE.H-4), --Function utils ? get min/max y...
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

        return UIElements
    end

    self.UI = createUI()
    
    self.bgWidth = globalAssets.images.homeBackground:getWidth()
    self.zoom = widthWindow/self.bgWidth

    self.panels = {
        {render = self.canvasDev, current = true},
        {render = self.canvasArt, current = false},
        {render = self.canvasSounds, current = false},
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
end

function Credits:update(dt)
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end
end

function Credits:render()
    love.graphics.scale(1/ratioScale, 1/ratioScale)
    love.graphics.origin()

    love.graphics.draw(globalAssets.images.homeBackground, 0, 0, 0, self.zoom)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
    love.graphics.setColor(1,1,1)

    love.graphics.print("Credits", 30, math.max(30, SAFEZONE.Y)+4, 0, 1.4)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 20, 80, widthWindow-40, heightWindow-140, 10)
    love.graphics.setColor(1, 1, 1, 1)

    for _, panel in pairs(self.panels) do
        if panel.current then
            panel.render(self)
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
    local font = love.graphics.getFont()
    font:setLineHeight(2)
    love.graphics.printf("Development\n\n"..
    "Game's creator : Tenecifer\n"..
    "Game engine : Love2D\n\n"..
    "Library used : \n"..
    "30log by Yonaba\n"..
    "Anim8 and Bump by Kikito\n"..
    "JSON by RXI\n"..
    "STI by Landon Manning",
    self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    font:setLineHeight(1)
end

function Credits:canvasArt()
    local font = love.graphics.getFont()
    font:setLineHeight(2)
    local title = "Art\n"
    love.graphics.printf(title, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    love.graphics.printf(
    "- Clouds by Artisan\n"..
    "- Cars by Kaneko\n"..
    "- Fire and explosion by BenHickling\n"..
    "- Smoke from FreePik\n"..
    "- Body of capyman by\n"..
    "- Tiles...\n"..
    "\n",
    self.zonePanel.x, self.zonePanel.y+Utils:getTextHeight(title, self.zonePanel.w), self.zonePanel.w)
    font:setLineHeight(1)
end

function Credits:canvasSounds()
    local font = love.graphics.getFont()
    font:setLineHeight(2)
    love.graphics.printf("Sounds\n\n"..
    "Musics by AudioDollar\n"..
    "Splatter by Independent.nu\n"..
    "Fire and obstacle collision by Jute\n"..
    "Explosion by Michel Baradari\n"..
    "Police siren, crash and motor from Pixabay \n"..
    "Cheering by ParadoxMirror\n"..
    "Car acceleration by B. Good Sounds\n"..
    "Horns by Car Features",
    self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    font:setLineHeight(1)
end