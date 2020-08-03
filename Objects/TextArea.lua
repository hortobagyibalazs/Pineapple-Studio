BackgroundColour = colors.white
SelectedBackgroundColour = colors.lightBlue
SelectedTextColour = colors.white
TextColour = colors.black
Text = {}
TextOffset = {X = 0, Y = 0}
CursorPos = {X = 1, Y = 1}
DragStart = {1, 1}
Dragging = false
TabSize = 2
Editable = true
OnTextChangeListeners = {}

OnDraw = function(self, x, y)
  -- Draw background
	Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)
  
  -- Display text
  self:DrawText(x, y)
  
  -- Display cursor if necessary
  if self.Bedrock:GetActiveObject() == self then
    self.Bedrock.CursorPos = {x + self.CursorPos.X - self.TextOffset.X - 1, y + self.CursorPos.Y - self.TextOffset.Y - 1}
    self.Bedrock.CursorColour = self.TextColour
  else
    self.CursorPos = {X = 0, Y = 0}
  end
  self:UpdateCursorVisibility(x, y)
end

OnUpdate = function(self)
  if #self.Text == nil then
    self.Text = {""}
  end
end

Reset = function(self)
  self.Text = {}
  
  self.CursorPos = {X = 1, Y = 1}
  self.TextOffset = {X = 0, Y = 0}
  
  self:ForceDraw()
end

UpdateCursorVisibility = function(self, x, y)
  local cursorX = self.CursorPos.X - self.TextOffset.X
  local cursorY = self.CursorPos.Y - self.TextOffset.Y
  
  if self.Bedrock:GetActiveObject() == self and (1 > cursorX or cursorX > self.Width or 1 > cursorY or cursorY > self.Height) then
    self.Bedrock.CursorPos = nil
  end
end

DrawText = function(self, x, y)  
  for i = 1, self.Height do
    local line = self.Text[i + self.TextOffset.Y]
    if line == nil then line = "" end
    line:sub(self.TextOffset.X)
        
    Drawing.DrawCharacters(x, y + i - 1, line, self.TextColour, self.BackgroundColour)
  end
end

DoChange = function(self, range)
  if self.CursorPos.X > self.Width + self.TextOffset.X then
    self.TextOffset.X = self.CursorPos.X - self.Width
  elseif self.CursorPos.X <= self.TextOffset.X then
    self.TextOffset.X = self.CursorPos.X
  end
  
  if self.CursorPos.Y > self.Height + self.TextOffset.Y then
    self.TextOffset.Y = self.CursorPos.Y - self.Height
  end
  
  for k, v in pairs(self.OnTextChangeListeners) do
    if v ~= nil then
      v(self, range)
    end
  end
end

AddOnTextChangeListener = function(self, callback)
  table.insert(self.OnTextChangeListeners, callback)
end

RemoveOnTextChangeListener = function(self, callback)
  table.remove(self.OnTextChangeListeners, callback)
end

RemoveOnTextChangeListeners = function(self)
  self.OnTextChangeListeners = {}
end

OnClick = function(self, event, side, x, y)
  self.Bedrock:SetActiveObject(self)

  if self.Text[y + self.TextOffset.Y] == nil and (y + self.TextOffset.Y ~= 1) then
    self.CursorPos.Y = #self.Text
    self.CursorPos.X = #(self.Text[self.CursorPos.Y]) + 1
    
    self:ForceDraw()
    
    return
  end
  
  self.CursorPos.X = x + self.TextOffset.X
  self.CursorPos.Y = y + self.TextOffset.Y
  
  local line = self.Text[self.CursorPos.Y]
  if line == nil then
    self.CursorPos.X = 1
  elseif #line < self.CursorPos.X then
    self.CursorPos.X = #line + 1
  end
  
  self.DragEnd = nil
  if not self.Dragging then
    self.DragStart = self.CursorPos
  end
  
  self:ForceDraw()
end

OnDrag = function(self, event, side, x, y)
  self.Dragging = true
  
	self:OnClick(event, side, x, y)
  
  self.DragEnd = {X = x, Y = y}
end

OnMouseRelease = function(self)
  self.Dragging = false
end

OnScroll = function(self, event, direction)
  local scrollingDown = (direction == 1)
  
  if (scrollingDown and #self.Text - self.TextOffset.Y > self.Height) or (not scrollingDown and self.TextOffset.Y > 0) then
    self.TextOffset.Y = self.TextOffset.Y + direction
    
    if self.OnTextOffsetChange then self:OnTextOffsetChange() end
    self:ForceDraw()
  end
  
  if (not scrollingDown) and self.TextOffset.Y + direction >= 0 then
    self.TextOffset.Y = self.TextOffset.Y + direction
    
    if self.OnTextOffsetChange then self:OnTextOffsetChange() end
    self:ForceDraw()
  end 
end

OnKeyChar = function(self, event, keychar)
  -- removes leading whitespaces from string
  local ltrim = function(s)
    return (s:gsub("^%s*", ""))
  end
  
	local deleteSelected = function()
	--[[	if self.Selected then
			local startPos = self.DragStart
			local endPos = self.CursorPos
			if startPos > endPos then
				startPos = self.CursorPos
				endPos = self.DragStart
			end
			self.Text = self.Text:sub(1, startPos) .. self.Text:sub(endPos + 2)
			self.CursorPos = startPos
			self.DragStart = nil
			self.Selected = false
			return true
		end--]]
	end

	if event == 'char' then
    if not self.Editable then return end
  
		--deleteSelected()
		if keychar == 'nil' then
			return
		end
    
    if self.Text[self.CursorPos.Y] == nil then self.Text[self.CursorPos.Y] = "" end
		self.Text[self.CursorPos.Y] = self.Text[self.CursorPos.Y]:sub(1, self.CursorPos.X - 1) .. keychar .. self.Text[self.CursorPos.Y]:sub(self.CursorPos.X)
		self.CursorPos.X = self.CursorPos.X + 1
    
    self:DoChange({self.CursorPos.Y, self.CursorPos.Y})
    
    self:ForceDraw()

		return false
	elseif event == 'key' then
		if keychar == keys.enter then
      if not self.Editable then return end
    
      local linePosX = #self.Text[self.CursorPos.Y] - #ltrim(self.Text[self.CursorPos.Y])
      local newLine = string.rep(" ", linePosX)..self.Text[self.CursorPos.Y]:sub(self.CursorPos.X)
      self.Text[self.CursorPos.Y] = self.Text[self.CursorPos.Y]:sub(1, self.CursorPos.X - 1)
      table.insert(self.Text, self.CursorPos.Y + 1, newLine)
      self.CursorPos = {X = linePosX + 1, Y = self.CursorPos.Y + 1}
      
      local offsetChanged = false
      if self.TextOffset.X ~= 0 then
        offsetChanged = true
      end
      self.TextOffset.X = 0
      
      if offsetChanged and self.OnTextOffsetChange then self:OnTextOffsetChange() end
      self:DoChange({self.CursorPos.Y - 1, self.CursorPos.Y})
      
      self:ForceDraw()
      
    elseif keychar == keys.left then
			-- Left
      self.CursorPos.X = self.CursorPos.X - 1
			if self.CursorPos.X < 1 then
        if self.CursorPos.Y > 1 then
          self.CursorPos = {X = #self.Text[self.CursorPos.Y - 1] + 1, Y = self.CursorPos.Y - 1}
        else
          self.CursorPos.X = 1
        end
      end
      
      self:ForceDraw()
      
		elseif keychar == keys.right then
			-- Right				
      local line = self.Text[self.CursorPos.Y]
      if line == nil then line = "" end
      self.CursorPos.X = self.CursorPos.X + 1
			if self.CursorPos.X > #line + 1 then
        self.CursorPos.X = 1
        
        if self.Text[self.CursorPos.Y + 1] ~= nil then 
          self.CursorPos.Y = self.CursorPos.Y + 1
        else
          self.CursorPos.X = #line
        end
      end
      
      self:ForceDraw()
      
    elseif keychar == keys.up then
      if self.CursorPos.Y > 1 then
        self.CursorPos.Y = self.CursorPos.Y - 1
      end
      
      if #self.Text[self.CursorPos.Y] < self.CursorPos.X then
        self.CursorPos.X = #self.Text[self.CursorPos.Y] + 1
      end
      
      self:ForceDraw()
      
    elseif keychar == keys.down then
      if self.CursorPos.Y < #self.Text then
        self.CursorPos.Y = self.CursorPos.Y + 1
      end
      
      if #self.Text[self.CursorPos.Y] < self.CursorPos.X then
        self.CursorPos.X = #self.Text[self.CursorPos.Y] + 1
      end
      
      self:ForceDraw()
      
		elseif keychar == keys.backspace then
      if not self.Editable then return end
    
      local range = {self.CursorPos.Y, self.CursorPos.Y}
			-- Backspace
			if self.CursorPos.X > 1 then
				self.Text[self.CursorPos.Y] = self.Text[self.CursorPos.Y]:sub(1, self.CursorPos.X - 2)..self.Text[self.CursorPos.Y]:sub(self.CursorPos.X) 
        self.CursorPos.X = self.CursorPos.X - 1
      elseif self.CursorPos.Y > 1 then
        if self.Text[self.CursorPos.Y - 1] == nil then self.Text[self.CursorPos.Y - 1] = "" end
        local length = #self.Text[self.CursorPos.Y - 1] 
        self.Text[self.CursorPos.Y - 1] = self.Text[self.CursorPos.Y - 1]..self.Text[self.CursorPos.Y]:sub(self.CursorPos.X)
        table.remove(self.Text, self.CursorPos.Y)
        self.CursorPos.Y = self.CursorPos.Y - 1
        self.CursorPos.X = length + 1
        
        range = {self.CursorPos.Y, self.CursorPos.Y + 1}
      end
      
      self:DoChange(range)
      self:ForceDraw()
    elseif keychar == keys.tab then
      if self.Text[self.CursorPos.Y] == nil then self.Text[self.CursorPos.Y] = "" end
		self.Text[self.CursorPos.Y] = self.Text[self.CursorPos.Y]:sub(1, self.CursorPos.X - 1) .. string.rep(" ", self.TabSize) .. self.Text[self.CursorPos.Y]:sub(self.CursorPos.X)
		self.CursorPos.X = self.CursorPos.X + self.TabSize
    
      self:DoChange({self.CursorPos.Y, self.CursorPos.Y})
      self:ForceDraw()
    elseif keychar == keys["end"] then
      local line = self.Text[self.CursorPos.Y]
      if line == nil then line = "" end
      
      self.CursorPos.X = #line + 1
      if self.CursorPos.X > self.Width + self.TextOffset.X then
        self.TextOffset.X = self.CursorPos.X - self.Width
      end
    
      self:ForceDraw()
    elseif keychar == keys.home then
      local line = self.Text[self.CursorPos.Y]
      if line == nil then line = "" end
      
      if self.CursorPos.X == 1 then
        local trimmedLine = ltrim(line)
        self.CursorPos.X = #line - #trimmedLine + 1
        if self.CursorPos.X > self.Width + self.TextOffset.X then
          self.TextOffset.X = self.CursorPos.X - self.Width
        end
      else
        self.CursorPos.X = 1
        self.TextOffset.X = 0
      end
    
      self:ForceDraw()
		end
    
    if self.OnKeyPress then self:OnKeyPress(keychar) end
	end
end