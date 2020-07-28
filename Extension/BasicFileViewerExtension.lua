function BasicFileViewer(scene)
  local self = FileViewer("Basic Lua file viewer")
  
  local lastContentChangeTime = nil
  
  function self.getFileCompatibilityLevel(path)
    if fs.isDir(path) then
      return 0
    else
      return 1
    end
  end
  
  function self.getLastContentChangeTime()
    return lastContentChangeTime
  end
  
  function self.getOpenFileContent()
    return tableToString(scene.getComponent("FileViewer").getObject("RootView"):GetObject("CodeBox").Text)
  end
  
  function self.getView()
    local function updateLineNumbers(root)
      if root == nil then
        root = scene.getComponent("FileViewer").getObject("RootView")
      end
      
      local list = root:GetObject("LineNumbersListView")
      local codeBox = root:GetObject("CodeBox")
      
      local begValue = codeBox.TextOffset.Y + 1
      local endValue = math.min(codeBox.TextOffset.Y + #codeBox.Text, codeBox.TextOffset.Y + codeBox.Height)
      
      list.Items = {}
      list.Width = #tostring(endValue)+1
      for i = begValue, endValue do
        table.insert(list.Items, {
          Type = "Label",
          Text = tostring(i)..":",
          X = 1,
          Align = "Right"
        })
      end
      
      codeBox.X = list.X + list.Width
    end
    
    local codeBox = {
      Name = "CodeBox",
      Type = "CodeBox",
      X = 1,
      Y = 1,
      RelativeWidth = "100%,-1",
      RelativeHeight = "100%,-1",
      OnLoad = function(_self)
        _self:Reset()

        local filePath = self.getOpenFilePath()
        local ps = scene.getComponent("ProjectManager").obtain().getProject().getProjectSettings()
        local values = ps.read()
        local data = values.Files[filePath]
        
        if data ~= nil then
          _self.TextOffset.X = data.OffsetX
          _self.TextOffset.Y = data.OffsetY
          _self.CursorPos.X = data.CursorX
          _self.CursorPos.Y = data.CursorY
          _self.Bedrock:SetActiveObject(_self)
        end

        Logger.log("BasicFileViewerExtension: Get file content from "..filePath)
        for line in io.lines(filePath) do
          table.insert(_self.Text, line)
        end
        _self.Tokens.parseCode(tableToString(_self.Text))
      
        _self.Editable = not fs.isReadOnly(filePath)
        
        _self:AddOnTextChangeListener(function(__self, range)
            lastContentChangeTime = os.clock()
          __self.Tokens.parseCode(tableToString(__self.Text))
          updateLineNumbers()
        end)
      
        _self.OnTextOffsetChange = function(__self)
          updateLineNumbers()
        end
      end
    }
    
    local lineNumbersListView = {
      Name = "LineNumbersListView",
      Type = "ListView",
      X = 1,
      Y = 1,
      Width = 0,
      RelativeHeight = "100%",
      ItemMargin = 0
    }
    
    return {
      Name = "RootView",
      Type = "ScrollView",
      X = 1,
      Y = 1,
      RelativeWidth = "100%",
      RelativeHeight = "100%",
      Children = {codeBox, lineNumbersListView},
      OnLoad = function(_self)
        updateLineNumbers(_self)
      end
    }
  end
  
  return self
end

function BasicFileViewerExtension()
  local self = Extension("Basic file viewer ext.")
  
  local timer = nil
  
  function self.onSceneLoad(scene)
    local viewer = scene.getComponent("FileViewer").addViewer(BasicFileViewer(scene))
    
    timer = scene.getComponent("Timer").startRepeatingTimer(function()
      local projectSettings = scene.getComponent("ProjectManager").obtain().getProject().getProjectSettings()
      
      local fileViewer = scene.getComponent("FileViewer")
      if fileViewer.getOpenFileViewer() == nil or fileViewer.getOpenFileViewer().getName() ~= viewer.getName() then
        return
      end
    
      local codeBox = fileViewer.getObject("RootView"):GetObject("CodeBox")
    
      local values = projectSettings.read()
      local tbl = values.Files
      tbl[fileViewer.getOpenFileViewer().getOpenFilePath()] = {
        OffsetX = codeBox.TextOffset.X,
        OffsetY = codeBox.TextOffset.Y,
        CursorX = codeBox.CursorPos.X,
        CursorY = codeBox.CursorPos.Y
      }

      projectSettings.edit("Files", tbl)  
    end, 1)
  end
  
  function self.onSceneUnload()
    scene.getComponent("Timer").stop(timer)
  end
  
  function self.handleSceneLoad(scene)
    return scene.getTag() == "ProjectViewScene"
  end
  
  return self
end

return BasicFileViewerExtension()