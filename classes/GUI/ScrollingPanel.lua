ScrollingPanel = class("ScrollingPanel")

function ScrollingPanel:init()
    self.visible = true
    
    self.panel = {
        x = 20, 
        y = 60, 
        w = widthWindow - 40, 
        h = heightWindow - 120 
    }
    self.scrollBar = { 
        rangeBar = { x = 300, y = 100, w = 10, h = 300 }, 
        selectBar = { x = 301, y = 101, w = 8, h = 50 } }

    self.marginInBounds = 10
    self.scrollBarWidth, self.scrollBarHeight = 10, 300
    self.innerBarDim = { w = self.scrollBarWidth-2, h = 50 }
    self.isScrolling = false
end

function ScrollingPanel:update()
    local mouseX, mouseY = input.state.mouse.x, input.state.mouse.y
    
    local function isMouseWithinScrollBar()
        local sb = self.scrollBar
        return mouseX >= sb.selectBar.x - self.marginInBounds and 
               mouseX <= sb.selectBar.x + sb.rangeBar.w + self.marginInBounds and 
               mouseY >= sb.selectBar.y - self.marginInBounds and 
               mouseY <= sb.selectBar.y + sb.rangeBar.h + self.marginInBounds
    end

    if input.state.actions.click and isMouseWithinScrollBar() then
        local sb = self.scrollBar
        sb.selectBar.y = math.max(sb.rangeBar.y+1, math.min(sb.rangeBar.y + sb.rangeBar.h - sb.selectBar.h-1, mouseY - sb.selectBar.h/2))
    end
end

function ScrollingPanel:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(3)
    
    local p, sb = self.panel, self.scrollBar
    love.graphics.rectangle("line", p.x, p.y, p.w, p.h)
    love.graphics.rectangle("line", sb.rangeBar.x, sb.rangeBar.y, sb.rangeBar.w, sb.rangeBar.h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", sb.selectBar.x, sb.selectBar.y, sb.rangeBar.w-2, 50)
end