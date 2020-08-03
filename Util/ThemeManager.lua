function ThemeManager(program)
  local self = {}
  
  local theme = nil
  local themeName = nil
  local resPath = program.ProgramPath.."/Theme"
  
  function self.loadTheme(name)
    local themePath = resPath.."/"..name..".theme"
    
    if fs.exists(themePath) then
      local f = fs.open(themePath, "r")
      if f then
        theme = textutils.unserialize(f.readAll())
        if theme then
          Logger.log("ThemeManager: Loaded theme '"..name.."'")
          
          if theme["Palette"] and (term.setPaletteColor ~= nil) then
            for colorName, colorVal in pairs(theme["Palette"]) do
              local colorTbl = colors
              local realColorName = colorName:sub(1, 1):lower()..colorName:sub(2)
            
              if colorTbl[realColorName] == nil and colours[realColorName] ~= nil then
                colorTbl = colours
              end
              
              term.setPaletteColor(colorTbl[realColorName], colorVal)
            end
          end
        else
          Logger.log("ThemeManager: Failed to load '"..name.."' theme. Probably file is incorrectly formatted.")
        end
      end
    else
      Logger.log("Couldn't find theme '"..name.."' at "..themePath)
    end
  end
  
  function self.applyTheme(view, _theme)
    local function stringToColor(str)
      if colors[str] then
        return colors[str]
      elseif colours[str] then
        return colours[str]
      end
    end
    
    local function applyValues(_view, values) 
      local propertyBlackList = {
        ["Type"] = true, 
        ["Name"] = true, 
        ["X"] = true, 
        ["Y"] = true, 
        ["Width"] = true, 
        ["Height"] = true,
        ["Children"] = true,
        ["Text"] = true
      }
      
      for k, v in pairs(values) do
        if not propertyBlackList[k] then
          _view[k] = stringToColor(v)
        end
      end
    end
        
    local newTheme = theme
    if _theme then newTheme = _theme end
    if (not newTheme) or (not view) then return end
    
    if newTheme[view.Type] then
      local defaultStyle = "Default"
      local viewStyle = view.Style
      
      local values = nil
      if newTheme[view.Type][viewStyle] then
        values = newTheme[view.Type][viewStyle]
      else
        -- iterate through every style for a specific UI element
        local highestCriteriasMet = 0
        for k, style in pairs(newTheme[view.Type]) do
          if k ~= defaultStyle then 
            local numberOfCriteriasMet = 0
            local meetsAllCriterias = true
          
            if style.ViewName then
              if style.ViewName == view.Name then
                numberOfCriteriasMet = numberOfCriteriasMet + 1
              else
                meetsAllCriterias = false
              end
            end
          
            if style.ParentName then
              if style.ParentName == view.ParentName then
                numberOfCriteriasMet = numberOfCriteriasMet + 1 
              else
                meetsAllCriterias = false
              end
            end
          
            if style.ParentType then
              if style.ParentType == view.ParentType then
                numberOfCriteriasMet = numberOfCriteriasMet + 1 
              else
                meetsAllCriterias = false
              end
            end
          
            if style.ParentStyle then
              if style.ParentStyle == view.ParentStyle then
                numberOfCriteriasMet = numberOfCriteriasMet + 1 
              else
                meetsAllCriterias = false
              end
            end
          
            if meetsAllCriterias and (numberOfCriteriasMet > highestCriteriasMet) then
              highestCriteriasMet = numberOfCriteriasMet
              values = style
            end
          end
        end
        
        if (values == nil) and newTheme[view.Type][defaultStyle] then
          values = newTheme[view.Type][defaultStyle]
        end
      end
      
      if values then
        applyValues(view, values)
      else
        --Logger.log("Theme Manager: Failed to apply values for view :( ")
      end
    end
    
    if view.Children then
      for k, v in pairs(view.Children) do
        v.ParentName = view.Name
        v.ParentType = view.Type
        v.ParentStyle = view.Style
        
        self.applyTheme(v)
      end
    end
  end
  
  function self.getTheme()
    return theme
  end
  
  function self.getThemeName()
    return themeName
  end
  
  return self
end