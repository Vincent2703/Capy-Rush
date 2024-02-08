ScrollingPanel = class("ScrollingPanel")

function ScrollingPanel:init()
    self.visible = true
 --fusionner panelpos et dim etc
    self.panelPos = {x=50, y=100}
    self.panelDim = {w=200, h=400}

    self.scrollBarPos = {x=300, y=100}
	self.innerBarPos = {x=self.scrollBarPos.x+1, y=self.scrollBarPos.y+1}
    self.marginInBounds = 10
	self.quotientScrollBarWidth = 0.02
	self.scrollBarWidth, self.scrollBarHeight = 10, 300
    self.innerBarDim = {w=self.scrollBarWidth-2, h=50}
	self.isScrolling = false
end

function ScrollingPanel:update()
    local mouseX, mouseY = input.state.mouse.x, input.state.mouse.y
    local function checkInBounds()
        return mouseX >= self.innerBarPos.x-self.marginInBounds and 
        mouseX <= self.innerBarPos.x+self.scrollBarWidth+self.marginInBounds and 
        mouseY >= self.innerBarPos.y-self.marginInBounds and 
        mouseY <= self.innerBarPos.y+self.scrollBarHeight+self.marginInBounds
    end

    if input.state.actions.click and checkInBounds() then
       -- print(mouseY)
        self.innerBarPos.y = math.max(self.scrollBarPos.y+1, math.min(self.scrollBarPos.y+self.scrollBarHeight-self.innerBarDim.h-1, mouseY-self.innerBarDim.h/2))
    end
end

function ScrollingPanel:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.scrollBarPos.x, self.scrollBarPos.y, self.scrollBarWidth, self.scrollBarHeight)
    love.graphics.setColor(1, 1, 1)

    love.graphics.rectangle("fill", self.innerBarPos.x, self.innerBarPos.y, self.scrollBarWidth-2, 50)
end