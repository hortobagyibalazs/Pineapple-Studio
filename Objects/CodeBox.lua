Inherit = "TextArea"
Tokens = TokenCache()
WhiteSpaceChar = "·"
HighlightSyntax = true
--[[Style = {
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
}]]

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

HighlightColour = colors.lightBlue
WhitespaceColour = colors.black
CommentColour = colors.green
StringColour = colors.red
EscapeColour = colors.red
KeywordColour = colors.blue
ValueColour = colors.purple
IdentColour = colors.black
NumberColour = colors.blue
SymbolColour = colors.black
OperatorColour = colors.black
UnidentifiedColour = colors.pink

OnLoad = function(self)
  self:AddOnTextChangeListener(function(_self, range)
    _self.Tokens.parseCode(tableToString(_self.Text))
  end)
end

DrawText = function(self, x, y)
  if self.CursorPos ~= nil and self.CursorPos.Y ~= nil and self.CursorPos.Y ~= 0 then
    Drawing.DrawBlankArea(x, y+self.CursorPos.Y-1-self.TextOffset.Y, self.Width, 1, self.HighlightColour)
  end
  
  local tokens = self.Tokens.getTokens()
  if tokens == nil or #tokens == 0 then
    for i = 1, self.Height do
      local line = self.Text[i + self.TextOffset.Y]
      if line == nil then line = "" end
      line:sub(self.TextOffset.X)
        
      Drawing.DrawCharacters(x, y + i - 1, line, self.IdentColour, self.BackgroundColour)
    end
    
    return
  end

  for i = 1, self.Height do
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
        bc = self.HighlightColour
      end
      local colorVal = self[type:sub(1, 1):upper()..type:sub(2).."Colour"]
      
      Drawing.DrawCharacters(x + posFirst - 1 - self.TextOffset.X, y + i - 1, data, colorVal, bc)  
    end
  end
end