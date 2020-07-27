function FileAutoSaveExtension()
  local self = Extension("File auto save")
  
  local timer = nil
  local lastAutoSavedContent = nil
  local lastChanged = nil
  
  function self.onSceneLoad(scene)
    timer = scene.getComponent("Timer").startRepeatingTimer(function()
      local lastSaveTime = scene.getComponent("FileViewer").getLastSaveTime()
      local viewer = scene.getComponent("FileViewer").getOpenFileViewer()
      if viewer == nil then return end
      local lastFileChangeTime = viewer.getLastContentChangeTime()
      --Logger.log(tostring(lastSaveTime).."   "..tostring(lastFileChangeTime))
      
      if ((lastFileChangeTime ~= nil and lastSaveTime ~= nil and lastFileChangeTime > lastSaveTime) or (lastFileChangeTime ~= nil and lastSaveTime == nil)) and (lastFileChangeTime ~= nil and os.clock() - lastFileChangeTime > 0.5) then
        scene.getComponent("FileViewer").saveOpenFile()
      end
    end, 1)
  end
  
  function self.onSceneUnload(scene)
    if scene.getTag() == "ProjectViewScene" then
      scene.getComponent("Timer").stop(timer)
    end
  end
  
  function self.handleSceneLoad(scene)
    return scene.getTag() == "ProjectViewScene"
  end
  
  return self
end

return FileAutoSaveExtension()