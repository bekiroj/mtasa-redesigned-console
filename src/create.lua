local adm = new('ADM')
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
local dxGetTextWidth = dxGetTextWidth
local getTickCount = getTickCount
local guiGetScreenSize = guiGetScreenSize
local getCursorPosition = getCursorPosition
local tocolor = tocolor
local ipairs = ipairs
local triggerServerEvent = triggerServerEvent
local getKeyState = getKeyState
local executeCommandHandler = executeCommandHandler
local addEvent = addEvent
local addEventHandler = addEventHandler
local removeEventHandler = removeEventHandler
local bindKey = bindKey
local unbindKey = unbindKey
local showChat = showChat
local showCursor = showCursor

function adm.prototype.____constructor(self)
	--/////////////////////////////////////////////////////////
	self._function = {}
	self._function.render = function(...) self:_render(self) end
	self._function.write = function(...) self:_write(self,...) end
	self._function.scrollUp = function(...) self:_scrollUp(self) end
	self._function.scrollDown = function(...) self:_scrollDown(self) end
	self._function.load = function(...) self:_load(self,...) end
	self._function.display = function(...) self:_display(self) end
	self._function.key = function(...) self:_key(self,...) end
	self._function.insert = function(...) self:_insert(self,...) end
	--/////////////////////////////////////////////////////////
	self.screen = Vector2(guiGetScreenSize())
	self.font = DxFont('assets/Roboto.ttf',12)
	self.lastCommands = {}
	self.isOn = false
	--/////////////////////////////////////////////////////////
	self:_getUtils(self)
end

function adm.prototype._render(self)
	dxDrawRectangle(0,0,self.screen.x,self.screen.y/2,tocolor(0,0,0,225))
	dxDrawRectangle(0,self.screen.y/2-25,self.screen.x,1,tocolor(214,214,214))
	dxDrawText('>', 10,self.screen.y/2-25,nil,nil, tocolor(214,214,214), 1, self.font)
	if getKeyState('backspace') and self.click+120 <= getTickCount() then
		self.click = getTickCount()
		self.text = self.text:sub(0, #self.text - 1)
	end
	dxDrawText('cmd.'..self.text, 28,self.screen.y/2-21,nil,nil, tocolor(233,210,119), 0.75, self.font)
	self.sizeText = dxGetTextWidth('cmd.'..self.text,0.75,self.font)
    dxDrawText('l', 28+(1*self.sizeText), self.screen.y/2-20, nil, nil, tocolor(214,214,214,self.alpha), 0.75, self.font)
    self.add = 0
    self.current = 0
    for index, value in ipairs(self.lastCommands) do
    	if index > self.currentRow and self.current < self.maxRow then
	    	dxDrawText(''..value[3]..':'..value[4]..'',90,25+self.add,nil,nil, tocolor(214,214,214), 0.75, self.font)
	    	dxDrawText(''..value[1]..' used.'..value[2],130,25+self.add,nil,nil, tocolor(233,210,119), 0.75, self.font)
	    	self.add = self.add + 15
	    	self.current = self.current + 1
	    end
    end
    dxDrawText('↓',110,25+self.add,nil,nil, tocolor(214,214,214), 1, self.font)
    self.add = 0
    self.current = 0
    for index, value in ipairs(self.commands) do
    	if index > self.currentRowCmd and self.current < self.maxRow then
    		dxDrawText('resource.'..value[1]..' / command.'..value[2],self.screen.x-450,25+self.add,nil,nil, tocolor(25,145,25), 0.75, self.font)
    		self.add = self.add + 15
	    	self.current = self.current + 1
	    end
    end
    dxDrawText('↓',self.screen.x-430,25+self.add,nil,nil, tocolor(214,214,214), 1, self.font)
    if self:isInBox(self.screen.x-600,0,600,500) then
    	self.selected = self.commands
    elseif self:isInBox(0,0,600,500) then
    	self.selected = self.lastCommands
    else
    	self.selected = nil
    end
    self.find = nil
    self.findRes = nil
    self.findCmd = nil
    self.string = self:_split(self.text, " ")
    for index, value in ipairs(self.commands) do
    	if self.text:sub(1, #self.string[1]) == value[2] then
    		self.find = true
    		self.findRes = value[1]
    		self.findCmd = value[2]
    	end
	end
	if self.find then
		dxDrawText('resource.'..self.findRes..' / command.'..self.findCmd, self.screen.x-450,self.screen.y/2-21,nil,nil, tocolor(25,145,25), 0.75, self.font)
	else
		dxDrawText('resource.? / command.?', self.screen.x-450,self.screen.y/2-21,nil,nil, tocolor(145,25,25), 0.75, self.font)
	end
	if getKeyState('enter') and self.click+120 <= getTickCount() then
		self.click = getTickCount()
		if string.len(self.text) > 0 then
			if self.text == 'close' then
				self:_display(self)
			else
				if self.find then
					self.string = self:_split(self.text, " ")
					self:_insert(self,localPlayer.name,self.text)
					executeCommandHandler(self.text:sub(1, #self.string[1]), self.text:sub(#self.string[1]+ 2, #self.text))
					triggerServerEvent('adm.interface.execute', localPlayer, self.text:sub(1, #self.string[1]), self.text:sub(#self.string[1]+ 2, #self.text))
					self.text = ''
				end
			end
		end
	end
end

function adm.prototype:_split(s, delimiter)
	-- taken from https://community.multitheftauto.com/?p=resources&s=details&id=18538
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function adm.prototype._display(self)
	if self.isOn then
		self.isOn = false
		self.commands = nil
		showChat(true)
		showCursor(false)
		removeEventHandler('onClientKey', root, self._function.key)
		removeEventHandler('onClientCharacter', root, self._function.write)
		removeEventHandler('onClientRender', root, self._function.render)
		unbindKey('mouse_wheel_up', 'down', self._function.scrollUp)
    	unbindKey('mouse_wheel_down', 'down', self._function.scrollDown)
		if isTimer(self.timer) then
			killTimer(self.timer)
		end
	else
		self.isOn = true
		self.find = nil
	    self.findRes = nil
	    self.findCmd = nil
	    self.selected = nil
		self.commands = {}
		self.click = 0
		self.text = ''
		self.currentRow = 0
		for index, value in ipairs(self.lastCommands) do
			self.currentRow = self.currentRow + 1
		end
		self.currentRow = self.currentRow - 25
		self.currentRowCmd, self.maxRow = 0, 25
		showChat(false)
		showCursor(true)
		self.timer = Timer(function()
	        if self.alpha == 0 then
	            self.alpha = 255
	        else
	            self.alpha = 0
	        end
	    end, 700, 0)
	    triggerServerEvent('adm.interface.load.server', localPlayer)
	    bindKey('mouse_wheel_up', 'down', self._function.scrollUp)
    	bindKey('mouse_wheel_down', 'down', self._function.scrollDown)
    	addEventHandler('onClientKey', root, self._function.key)
		addEventHandler('onClientCharacter', root, self._function.write)
		addEventHandler('onClientRender', root, self._function.render, true, 'low-10')
	end
end

function adm.prototype:_key(self,key)
	if self.isOn then
		if key == 'insert' then return false end
		if key == 'mouse_wheel_up' then return false end
		if key == 'mouse_wheel_down' then return false end
		cancelEvent()
	end
end

function adm.prototype:_load(self,table)
	self.commands = table
end

function adm.prototype._getUtils(self)
	bindKey('insert', 'down', self._function.display)
	addEvent('adm.interface.add.client', true)
	addEventHandler('adm.interface.add.client', root, self._function.insert)
	addEvent('adm.interface.load.client', true)
	addEventHandler('adm.interface.load.client', root, self._function.load)
end

function adm.prototype:_insert(self,name,command)
	self.hours = getRealTime().hour
	if self.hours <= 9 then
		self.hours = '0'..self.hours
	end
	self.minutes = getRealTime().minute
	if self.minutes <= 9 then
		self.minutes = '0'..self.minutes
	end
	table.insert(self.lastCommands, {name, command, self.hours, self.minutes})
end

function adm.prototype._scrollUp(self)
	if self.isOn then
		if self.selected == self.commands then
			if self.currentRowCmd > 0 then
				self.currentRowCmd = self.currentRowCmd - 1
			end
		elseif self.selected == self.lastCommands then
			if self.currentRow > 0 then
				self.currentRow = self.currentRow - 1
			end
		end
	end
end

function adm.prototype._scrollDown(self)
	if self.isOn then
		if self.selected == self.commands then
			if self.currentRowCmd < #self.selected - self.maxRow then
				self.currentRowCmd = self.currentRowCmd + 1
	        end
		elseif self.selected == self.lastCommands then
			if self.currentRow < #self.selected - self.maxRow then
				self.currentRow = self.currentRow + 1
	        end
	    end
	end
end

function adm.prototype:_write(self, char)
	if self.isOn then
		if string.len(self.text) <= 30 then
        	self.text = ''..self.text..''..char
        end
	end
end

function adm.prototype:isInBox(xS,yS,wS,hS)
    if(isCursorShowing()) then
        local cursorX, cursorY = getCursorPosition()
        sX,sY = guiGetScreenSize()
        cursorX, cursorY = cursorX*sX, cursorY*sY
        if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
            return true
        else
            return false
        end
    end
end

adm = load(adm)