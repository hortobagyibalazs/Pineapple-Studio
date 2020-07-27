Inherit = "TextArea"
Tokens = TokenCache()
WhiteSpaceChar = "·"
HighlightSyntax = true
Style = {
    ["highlight"] = colors.lightBlue,
    ["background"] = colors.gray,
    ["whitespace"] = {["tc"] = colors.black, ["bc"] = colors.transparent},
    ["comment"] = {["tc"] = colors.green, ["bc"] = colors.transparent},
    ["string"] = {["tc"] = colors.red, ["bc"] = colors.transparent},
    ["escape"] = {["tc"] = colors.red, ["bc"] = colors.transparent},
    ["keyword"] = {["tc"] = colors.cyan, ["bc"] = colors.transparent},
    ["value"] = {["tc"] = colors.yellow, ["bc"] = colors.transparent},
    ["ident"] = {["tc"] = colors.lightGray, ["bc"] = colors.transparent},
    ["number"] = {["tc"] = colors.yellow, ["bc"] = colors.transparent},
    ["symbol"] = {["tc"] = colors.lightGray, ["bc"] = colors.transparent},
    ["operator"] = {["tc"] = colors.lightGray, ["bc"] = colors.transparent},
    ["unidentified"] = {["tc"] = colors.pink, ["bc"] = colors.white}
}

--[[Style = {
    ["highlight"] = colors.lightGray,
    ["background"] = colors.white,
    ["whitespace"] = {["tc"] = colors.black, ["bc"] = colors.transparent},
    ["comment"] = {["tc"] = colors.green, ["bc"] = colors.transparent},
    ["string"] = {["tc"] = colors.red, ["bc"] = colors.transparent},
    ["escape"] = {["tc"] = colors.red, ["bc"] = colors.transparent},
    ["keyword"] = {["tc"] = colors.blue, ["bc"] = colors.transparent},
    ["value"] = {["tc"] = colors.purple, ["bc"] = colors.transparent},
    ["ident"] = {["tc"] = colors.black, ["bc"] = colors.transparent},
    ["number"] = {["tc"] = colors.blue, ["bc"] = colors.transparent},
    ["symbol"] = {["tc"] = colors.black, ["bc"] = colors.transparent},
    ["operator"] = {["tc"] = colors.black, ["bc"] = colors.transparent},
    ["unidentified"] = {["tc"] = colors.pink, ["bc"] = colors.white}
}]]

OnLoad = function(self)
  self:AddOnTextChangeListener(function(_self, range)
    _self.Tokens.parseCode(tableToString(_self.Text))
  end)
end

OnUpdate = function(self)
  self.BackgroundColour = self.Style.background
end

DrawText = function(self, x, y)
  if self.CursorPos ~= nil and self.CursorPos.Y ~= nil and self.CursorPos.Y ~= 0 then
    Drawing.DrawBlankArea(x, y+self.CursorPos.Y-1-self.TextOffset.Y, self.Width, 1, self.Style.highlight)
  end
  
  local tokens = self.Tokens.getTokens()
  if tokens == nil or #tokens == 0 then
    for i = 1, self.Height do
      local line = self.Text[i + self.TextOffset.Y]
      if line == nil then line = "" end
      line:sub(self.TextOffset.X)
        
      Drawing.DrawCharacters(x, y + i - 1, line, self.TextColour, self.BackgroundColour)
    end
    
    return
  end

  for i = 1, self.Height do
    local line = self.Text[i + self.TextOffset.Y]
    if line == nil then line = "" end
    line = line:sub(self.TextOffset.X)
    
    local tokensAtLine = self.Tokens.getTokenAt(i + self.TextOffset.Y)
    if tokensAtLine == nil then
      break
    end
    
    for k, token in pairs(tokensAtLine) do
      local type = token["type"]
      local data = token["data"]
      local posFirst = token["posFirst"]
      local posLast = token["posLast"]
        
      if type == "whitespace" then
        data = string.rep(self.WhiteSpaceChar:sub(1, 1), #data)
      end
      
      local bc = self.BackgroundColour
      if i + self.TextOffset.Y == self.CursorPos.Y then
        bc = self.Style.highlight
      end
      Drawing.DrawCharacters(x + posFirst - 1, y + i - 1, data, self.Style[type]["tc"], bc)  
    end
  end
  
  if self.DragStart and self.DragEnd then
    Logger.log("DS_x: "..self.DragStart.X.."   DS_y: "..self.DragStart.Y.."   DE_x: "..self.DragEnd.X.."   DE_y: "..self.DragEnd.Y)
  end
end