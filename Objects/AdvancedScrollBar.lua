Inherit = "ScrollBar"
Vertical = nil
AutoScrollBarType = nil
MinBarSize = 1

OnUpdate = function(self)
  if self.Vertical == nil then
    self.AutoScrollBarType = true
  end
  
  if self.AutoScrollBarType then
    self.Vertical = self.Height > self.Width
  end
end

OnDraw = function(self, x, y)
  local max = self.Width
  
  local barWidth = nil
  local barHeight = nil
  local barX = nil
  local barY = nil
  
  if self.Vertical then
    max = self.Height
  end
  
  local barSize = max * (max / (max + self.MaxScroll))
  if barSize < self.MinBarSize then
    barSize = self.MinBarSize
  end
  
  local percentage = (self.Scroll/self.MaxScroll)
  
  if self.Vertical then
    barHeight = barSize
    barWidth = self.Width
    barX = 0
    barY = math.ceil(max*percentage - barHeight*percentage)
  else
    barHeight = self.Height
    barWidth = barSize
    barX = math.ceil(max*percentage - barWidth*percentage)
    barY = 0
  end
  
  Drawing.DrawBlankArea(x, y, self.Width, self.Height, self.BackgroundColour)
  Drawing.DrawBlankArea(x + barX, y + barY, barWidth, barHeight, self.BarColour)
end

OnClick = function(self, event, side, x, y)
  local clickAxis = x
  local max = self.Width
  
  if self.Vertical then
    clickAxis = y
    max = self.Height
  end
  
  if event == 'mouse_click' then
    self.ClickPoint = y
  else
    if self.ClickPoint then
      local gapSize = max - (max * (max / (max + self._MaxScroll)))
      local barSize = max * (max / (max + self._MaxScroll))
      local delta = ((clickAxis - self.ClickPoint)/gapSize)*self.MaxScroll
      self.Scroll = self.Bedrock.Helpers.Round(delta)
      if self.Scroll < 0 then
        self.Scroll = 0
      elseif self.Scroll > self.MaxScroll then
        self.Scroll = self.MaxScroll
      end
    end
  end

  local relScroll = self.MaxScroll * ((clickAxis-1)/max)
  if clickAxis == max then
    relScroll = self.MaxScroll
  end
  self.Scroll = self.Bedrock.Helpers.Round(relScroll)
  
  if self.OnChange then
    self:OnChange()
  end
end