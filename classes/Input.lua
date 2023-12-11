Input = class("Input")

function Input:init()
	self.config = {
					right = "right",
					down = "down",
					up = "up",
					left = "left",
					boost = "lshift",
					eject = "space",
					pause = 'p'
				   }
				   
	self.state = {}
	self.state.mouse = {
						absX = nil, 
						absY = nil, 
						relX = nil,
						relY = nil
						}					
	self.state.actions = {
						right = false,
						down = false,
						up = false,
						left = false,
						boost = false,
						eject = false,
						click = false,
						pause = false,
						newPress = {
							right = false,
							down = false,
							left = false,
							boost = false,
							eject = false,
							click = false,
							pause = false
							}
						}
				
	self.prevState = self.state
end

function Input:update()
	self.prevState = self:copyState(self.state)

	-- Mouse
	local mouseX, mouseY = love.mouse.getPosition()
	self.state.mouse = {absX=mouseX, absY=mouseY, relX=(mouseX-offsetXCanvas)/ratioScale, relY=(mouseY-camYOffset)/ratioScale}
	
	self.state.actions.click = love.mouse.isDown(1, 2)
	self.state.actions.newPress.click = self.state.actions.click and not self.prevState.actions.click
	
	-- Keyboard
	self.state.actions.right = love.keyboard.isDown(self.config.right)
	self.state.actions.newPress.right = self.state.actions.right and not self.prevState.actions.right
	
	self.state.actions.down = love.keyboard.isDown(self.config.down)
	self.state.actions.newPress.down = self.state.actions.down and not self.prevState.actions.down

	self.state.actions.up = love.keyboard.isDown(self.config.up)
	self.state.actions.newPress.up = self.state.actions.up and not self.prevState.actions.up
	
	self.state.actions.left = love.keyboard.isDown(self.config.left)
	self.state.actions.newPress.left = self.state.actions.left and not self.prevState.actions.left
	
	self.state.actions.boost = love.keyboard.isDown(self.config.boost)
	self.state.actions.newPress.boost = self.state.actions.boost and not self.prevState.actions.boost
	
	self.state.actions.eject = love.keyboard.isDown(self.config.eject)
	self.state.actions.newPress.eject = self.state.actions.eject and not self.prevState.actions.eject
	
	self.state.actions.pause = love.keyboard.isDown(self.config.pause)
	self.state.actions.newPress.pause = self.state.actions.pause and not self.prevState.actions.pause
end

function Input:copyState(state)
	local copyState = {}
	copyState.mouse = {
		absX = state.mouse.absX,
		absY = state.mouse.absY,
		relX = state.mouse.relX,
		relY = state.mouse.relY
	}
    copyState.actions = {
        right = state.actions.right,
        down = state.actions.down,
		up = state.actions.up,
        left = state.actions.left,
        boost = state.actions.boost,
        eject = state.actions.eject,
        click = state.actions.click,
        pause = state.actions.pause,
        newPress = {
            right = state.actions.newPress.right,
            down = state.actions.newPress.down,
			up = state.actions.newPress.up,
            left = state.actions.newPress.left,
            boost = state.actions.newPress.boost,
            eject = state.actions.newPress.eject,
            click = state.actions.newPress.click,
            pause = state.actions.newPress.pause,
        }
    }
	return copyState
end