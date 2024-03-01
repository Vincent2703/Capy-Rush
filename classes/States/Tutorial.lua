Tutorial = class("Tutorial")

function Tutorial:init()
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
            math.min(heightWindow-50, SAFEZONE.Y+SAFEZONE.H-10), 
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

    self.direction = 1

    self.animations = {
        movingCar = {
            direction = -1,
            anim = anim8.newAnimation(globalAssets.animations.movingCar.grid("1-6", 1, "1-6", 2, "1-6", 3, "1-6", 4, "1-6", 5, "1-6", 6, "1-6", 7, "1-6", 8, 1, 9), {["1-48"]=1/12, ["49-49"]=1})
        },
        ejection = {
            direction = -1,
            anim = anim8.newAnimation(globalAssets.animations.ejection.grid("1-6", 1, "1-6", 2, "1-6", 3, "1-6", 4, "1-6", 5, "1-6", 6, "1-6", 7, "1-6", 8, "1-2", 9), {["1-49"]=1/12, ["50-50"]=1})
        },
        
        tiltX = {
            direction = 1,
            anim = anim8.newAnimation(globalAssets.animations.phoneTilts.grid("1-31", 1), 0.06, 
            function(anim, loops) 
                if self.animations.tiltX.direction == 1 then
                    self.animations.tiltX.direction = -1
                    self.animations.tiltX.anim:gotoFrame(30)
                else
                    self.animations.tiltX.direction = 1
                    self.animations.tiltX.anim:gotoFrame(2)
                end 
            end)
        },

        tiltY = {
            direction = 1,
            anim = anim8.newAnimation(globalAssets.animations.phoneTilts.grid("1-31", 2), 0.06, 
            function(anim, loops) 
                if self.animations.tiltY.direction == 1 then
                    self.animations.tiltY.direction = -1
                    self.animations.tiltY.anim:gotoFrame(30)
                else
                    self.animations.tiltY.direction = 1
                    self.animations.tiltY.anim:gotoFrame(2)
                end 
            end)
        },        

        tiltZ = {
            direction = 1,
            anim = anim8.newAnimation(globalAssets.animations.phoneTilts.grid("1-31", 3), 0.06, 
            function(anim, loops) 
                if self.animations.tiltZ.direction == 1 then
                    self.animations.tiltZ.direction = -1
                    self.animations.tiltZ.anim:gotoFrame(30)
                else
                    self.animations.tiltZ.direction = 1
                    self.animations.tiltZ.anim:gotoFrame(2)
                end 
            end)
        },

        touch = {
            direction = 1,
            anim = anim8.newAnimation(globalAssets.animations.phoneTouch.grid("1-6", 1), 0.1, 
            function(anim, loops) 
                if self.animations.touch.direction == 1 then
                    self.animations.touch.direction = -1
                    self.animations.touch.anim:gotoFrame(5)
                else
                    self.animations.touch.direction = 1
                    self.animations.touch.anim:gotoFrame(2)
                end 
            end)
        }
    }

    self.panels = {
        {render = self.canvas1, current = true},
        {render = self.canvas2, current = false},
        {render = self.canvas3, current = false},
        {render = self.canvas4, current = false}
    }
    self.zonePanel = {x=25, y=90, w=widthWindow-50, h=heightWindow-160}
end

function Tutorial:start()
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

function Tutorial:update(dt)
    for key, ui in pairs(self.UI) do 
        if ui.visible then
            ui:update()
        end
    end

    for _, anim in pairs(self.animations) do
        anim.anim:update(dt*anim.direction)
    end
end

function Tutorial:render()
    love.graphics.scale(1/ratioScale, 1/ratioScale)
    love.graphics.origin()

    love.graphics.draw(globalAssets.images.homeBackground, 0, 0, 0, self.zoom)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, widthWindow, heightWindow)
    love.graphics.setColor(1,1,1)

    love.graphics.print("Tutorial", 30, math.max(30, SAFEZONE.Y), 0, 1.4) --Element Title

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

function Tutorial:canvas1()
    local font = love.graphics.getFont()

    font:setLineHeight(2)
    love.graphics.printf("Welcome !\n"..
    "You play Capyman. The capybara with a human body.\n\n"..
    "He is the result of an experiment and escaped from the zoological laboratory in which he was captive.\n\n"..
    "His goal, and now yours too, is to escape as far as possible.\n\n"..
    "To do this, you will take the highway reserved for autonomous vehicles. Unfortunately, you will only be able to control a vehicle for a limited time before it stops.", 
    self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    font:setLineHeight(1)
end

function Tutorial:canvas2()
    local font = love.graphics.getFont()
    local phoneTilts = globalAssets.animations.phoneTilts

    font:setLineHeight(2)
    local txt1 = "How to 1/3\nTo move your car, tilt your phone to the right or to the left. If you are lying down, tilt the top of your phone."
    local txt2 = "You can adjust the sensibility of these controls in the settings."
    local txt1Height = Utils:getTextHeight(txt1, self.zonePanel.w)

    love.graphics.printf(txt1, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    self.animations.tiltY.anim:draw(phoneTilts.spritesheet, self.zonePanel.w/2-phoneTilts.spriteWidth, self.zonePanel.y+txt1Height)
    self.animations.tiltZ.anim:draw(phoneTilts.spritesheet, self.zonePanel.w/2+phoneTilts.spriteWidth/2, self.zonePanel.y+txt1Height)
    love.graphics.printf(txt2, self.zonePanel.x, self.zonePanel.y+txt1Height+phoneTilts.spriteHeight+10, self.zonePanel.w, "center")
    self.animations.movingCar.anim:draw(globalAssets.animations.movingCar.spritesheet, self.zonePanel.x+self.zonePanel.w/2-globalAssets.animations.movingCar.spriteWidth/2, self.zonePanel.y+90+txt1Height+Utils:getTextHeight(txt2, self.zonePanel.w))
    font:setLineHeight(1)
end

function Tutorial:canvas3()
    local font = love.graphics.getFont()
    local phoneTilts = globalAssets.animations.phoneTilts

    font:setLineHeight(2)
    local txt1 = "How to 2/3\nTo switch to another car, you can eject yourself. Touch the screen to do so."
    local txt2 = "You can adjust your trajectory by tilting your phone."
    local txt3 = "Touch the screen again to land quicker."
    local txt1Height = Utils:getTextHeight(txt1, self.zonePanel.w)

    love.graphics.printf(txt1, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    self.animations.touch.anim:draw(globalAssets.animations.phoneTouch.spritesheet, self.zonePanel.x+self.zonePanel.w/2-globalAssets.animations.phoneTouch.spriteWidth/2, self.zonePanel.y+txt1Height)
    
    local yPos = self.zonePanel.y+txt1Height+globalAssets.animations.phoneTouch.spriteHeight+10
    love.graphics.printf(txt2, self.zonePanel.x, yPos, self.zonePanel.w, "center")
    yPos = yPos+Utils:getTextHeight(txt2, self.zonePanel.w+5)

    local middleXPos = math.ceil(self.zonePanel.x+self.zonePanel.w/2-phoneTilts.spriteWidth/2)
    self.animations.tiltX.anim:draw(phoneTilts.spritesheet, middleXPos-phoneTilts.spriteWidth, yPos)
    self.animations.tiltY.anim:draw(phoneTilts.spritesheet, middleXPos, yPos)
    self.animations.tiltZ.anim:draw(phoneTilts.spritesheet, middleXPos+phoneTilts.spriteWidth, yPos)

    yPos = yPos+10+phoneTilts.spriteHeight
    self.animations.ejection.anim:draw(globalAssets.animations.ejection.spritesheet, self.zonePanel.x+self.zonePanel.w/2-globalAssets.animations.ejection.spriteWidth/2, yPos)
    Utils:printCtrTxtWScl(txt3, yPos+globalAssets.animations.ejection.spriteHeight+5, 0.8)

    font:setLineHeight(1)
end

function Tutorial:canvas4()
    local font = love.graphics.getFont()
    local globalImgs = globalAssets.images
    local lvl = globalImgs.lvl
    local fuel = globalImgs.fuel
    local signs = globalImgs.signs

    font:setLineHeight(2)
    local txt1 = "How to 3/3\nThe current level of difficulty is displayed on the upper left corner of the screen."
    local txt2 = "The red bar at the bottom of the screen represents the car's autonomy. You need to switch to another car before it becomes empty."
    local txt3 = "Be careful to the road signs to know which lane to take."
    local txt1Height = Utils:getTextHeight(txt1, self.zonePanel.w) -10
    local txt2Height = Utils:getTextHeight(txt2, self.zonePanel.w) -10
    local txt3Height = Utils:getTextHeight(txt3, self.zonePanel.w) -10
    local middleXPos = self.zonePanel.x+self.zonePanel.w/2

    love.graphics.printf(txt1, self.zonePanel.x, self.zonePanel.y, self.zonePanel.w, "center")
    love.graphics.draw(lvl, math.ceil(middleXPos-lvl:getWidth()/2), self.zonePanel.y+txt1Height)
    
    local yPos = self.zonePanel.y+txt1Height+lvl:getHeight()+15
    love.graphics.printf(txt2, self.zonePanel.x, yPos, self.zonePanel.w, "center")
    love.graphics.draw(fuel, math.ceil(middleXPos-fuel:getWidth()/2), yPos+txt2Height)

    yPos = yPos+txt2Height+fuel:getHeight()+15
    love.graphics.printf(txt3, self.zonePanel.x, yPos, self.zonePanel.w, "center")
    love.graphics.draw(signs, math.ceil(middleXPos-signs:getWidth()/2), yPos+txt3Height)


    font:setLineHeight(1)
end