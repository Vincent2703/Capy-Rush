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
						x = nil, 
						y = nil, 
						relX = nil,
						relY = nil
						}			
	self.state.joystick = {
						x = 1,
						y = 1,
						z = 1,
						tiltX = 1,
						tiltZ = 1
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


	self.phoneBackPressed = false
	self.startingJoyZ = 0
	self.diff = 0
end

function Input:update()
	self.prevState = self:copyState(self.state)
	-- Mouse
	local mouseX, mouseY = love.mouse.getPosition()
	self.state.mouse = {x=mouseX, y=mouseY}
	
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
	
	self.state.actions.pause = love.keyboard.isDown(self.config.pause) or self.phoneBackPressed
	if self.phoneBackPressed then
		self.phoneBackPressed = false
	end
	self.state.actions.newPress.pause = self.state.actions.pause and not self.prevState.actions.pause

	-- Joystick
	if self.config.joystick then
		local x, y, z = self.config.joystick:getAxes()
		local normOfG = math.sqrt(x * x + y * y + z * z)
		
		self.state.joystick.x, self.state.joystick.y, self.state.joystick.z = x, y, z
		local nx, ny, nz = x / normOfG, y / normOfG, z / normOfG
		
		local inclination = math.floor(math.deg(math.acos(nz)) + 0.5)
		local rotation = math.deg(math.atan2(nx, ny)) / 90
		local rotationCropped = math.max(-1, math.min(rotation / 0.85, 1))
		
		local tx = x
		
		local turnLeft, turnRight = false, false
		
		if tx < -0.1 then
			turnLeft = true
		elseif tx > 0.1 then
			turnRight = true
		elseif math.abs(z) <= 0.1 then
			if tx < 0 then
				turnLeft = true
			elseif tx > 0 then
				turnRight = true
			end
		end		
		
		self.state.actions.right = self.state.actions.right or turnRight
		self.state.actions.left = self.state.actions.left or turnLeft
		self.state.joystick.tiltX = math.abs(rotationCropped)
	
		local deviation = (y > 0) and (z - self.startingJoyZ) or (-(y - self.startingJoyZ)*2)
		local deviaNorma = math.abs(deviation)
		local deviaBoost = math.min(1, deviaNorma*1.5)
		self.state.joystick.tiltZ = deviaBoost
	
		self.state.actions.up = self.state.actions.up or (deviation > 0)
		self.state.actions.down = self.state.actions.down or (deviation < 0)
	end
	
	
end

function Input:copyState(state)
	local copyState = {}
	copyState.mouse = {
		x = state.mouse.x,
		y = state.mouse.y,
		relX = state.mouse.relX,
		relY = state.mouse.relY
	}
	copyState.joystick = {
		x = state.joystick.x,
		y = state.joystick.y,
		z = state.joystick.z,
		tiltX = state.joystick.tiltX,
		tiltZ = state.joystick.tiltZ,
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

function Input:setCurrentJoyZ()
	if self.config.joystick ~= nil then
		if z ~= 1 then
			self.startingJoyZ = self.config.joystick:getAxis(3)
		else
			self.startingJoyZ = -(self.config.joystick:getAxis(2))
		end
	end
end