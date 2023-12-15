Input = class("Input")

function Input:init()
	self.config = {
					right = "right",
					down = "down",
					up = "up",
					left = "left",
					boost = "lshift",
					eject = "space",
					pause = "escape",

					joystick = love.joystick.getJoysticks()[1]
				   }
				   
	self.state = {}
	self.state.mouse = {
						absX = nil, 
						absY = nil, 
						relX = nil,
						relY = nil
						}			
	self.state.joystick = {
						x = 1,
						y = 1,
						z = 1,
						inclinXRatio = 1,
						inclinZRatio = 1
	}
	self.state.actions = {
						right = false,
						down = false,
						up = false,
						left = false,
						eject = false,
						click = false,
						pause = false,
						newPress = {
							right = false,
							down = false,
							left = false,
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
	
	self.state.actions.eject = love.keyboard.isDown(self.config.eject)
	self.state.actions.newPress.eject = self.state.actions.eject and not self.prevState.actions.eject
	
	self.state.actions.pause = love.keyboard.isDown(self.config.pause)
	self.state.actions.newPress.pause = self.state.actions.pause and not self.prevState.actions.pause

	-- Joystick
	if self.config.joystick ~= nil then
		local x, y, z = self.config.joystick:getAxes()
		self.state.joystick.x, self.state.joystick.y, self.state.joystick.z = x, y, z

		self.state.actions.right = self.state.actions.right or x > 0.1
		self.state.actions.left = self.state.actions.left or x < -0.1
		self.state.joystick.inclinXRatio = math.max(math.min((math.abs(x)-0.1)/0.6, 1), 0)

		self.state.actions.up = self.state.actions.up or z >= 0.6
		self.state.actions.down = self.state.actions.down or z < 0.6
		if z >= 0.6 then
			self.state.joystick.inclinZRatio = math.max(math.min(math.abs(z-0.5)/0.4, 1), 0)
		else
			self.state.joystick.inclinZRatio = math.max(math.min(math.abs(z-0.6)/0.4, 1), 0)
		end
	end
end

function Input:copyState(state)
	local copyState = {}
	copyState.mouse = {
		absX = state.mouse.absX,
		absY = state.mouse.absY,
		relX = state.mouse.relX,
		relY = state.mouse.relY
	}
	copyState.joystick = {
		x = state.joystick.x,
		y = state.joystick.y,
		z = state.joystick.z,
		inclinXRatio = state.joystick.inclinXRatio,
		inclinZRatio = state.joystick.inclinZRatio,
	}
    copyState.actions = {
        right = state.actions.right,
        down = state.actions.down,
		up = state.actions.up,
        left = state.actions.left,
        eject = state.actions.eject,
        click = state.actions.click,
        pause = state.actions.pause,
        newPress = {
            right = state.actions.newPress.right,
            down = state.actions.newPress.down,
			up = state.actions.newPress.up,
            left = state.actions.newPress.left,
            eject = state.actions.newPress.eject,
            click = state.actions.newPress.click,
            pause = state.actions.newPress.pause,
        }
    }
	return copyState
end