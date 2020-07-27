local function scanDir(path, deepScan)
  local fileTree = {}
  if fs.isDir(path) then
    for k, v in pairs(fs.list(path)) do
      if fs.isDir(path.."/"..v) then
        local dir = {Name = v, Type = "Folder", Path = path, Children = {}}
        if deepScan then
          dir.Children = scanDir(path.."/"..v)
        end
        table.insert(fileTree, dir)
      else
        table.insert(fileTree, {Name = v, Type = "File", Path = path})
      end
    end
    
    return fileTree
  else
    return {Name = fs.getName(path), Type = "File", Path = path}
  end
end

local currentDir = nil
local function loadListItems(scene, list, files)
  list.Items = {}
  for i, v in ipairs(files) do
    table.insert(list.Items, {
      RelativeWidth = "100%",
      Text = v.Name
    })
    currentDir = v.Path
  end
end

function FileExplorerToolBarExtension()
  local self = Extension("File explorer")
  
  function self.onSceneLoad(scene)
    local listView = {
      Name = "FileTreeView",
      Type = "ListView",
      X = 1,
      Y = 1,
      RelativeWidth = "100%",
      RelativeHeight = "100%",
      BackgroundColour = "white"
    }
    
    listView.OnSelect = function(_self, item)
      if item == ".." then
        -- navigate up
        local parentDirItems = scanDir(fs.getDir(currentDir))
        loadListItems(scene, _self, parentDirItems)
      elseif fs.isDir(currentDir.."/"..item) then
        -- open folder
        local children = scanDir(currentDir.."/"..item)
        loadListItems(scene, _self, children)
          
        if currentDir ~= scene.getComponent("ProjectManager").obtain().getProject().getProjectDir() then
          table.insert(_self.Items, 1, {
            RelativeWidth = "100%",
            Text = ".."
          })
        end
      else
        -- open file
        Logger.log("Open file "..currentDir.."/"..item)
        scene.getComponent("FileViewer").openFile(currentDir.."/"..item)
      end    
    end
  
    loadListItems(scene, listView, scene.getComponent("ProjectManager").obtain().getProject().getProjectTree())
    scene.getComponent("ToolBar").add("File explorer", listView)
  end
  
  function self.handleSceneLoad(scene)
    return scene.getTag() == "ProjectViewScene"
  end
  
  return self
end

return FileExplorerToolBarExtension()

