function SharedPreferences(_path)
  local self = {}
  
  local filePath = _path
  
  local function createFileIfNotExists(path)
    if not fs.exists(path) then
      local file = fs.open(path, "w")
      file.close()
    end
  end
  
  function self.getFilePath()
    return filePath
  end
  
  function self.read()
    createFileIfNotExists(self.getFilePath())

    local file = fs.open(self.getFilePath(), "r")
    self.values = textutils.unserialize(file.readAll())
    file.close()  
    
    return self.values
  end
  
  function self.getOrDefault(key, default) 
    if self.values ~= nil and self.values.key ~= nil then
      return self.values.key
    else
      return default
    end
  end
  
  function self.edit(key, value)
    createFileIfNotExists(self.getFilePath())

    local file = fs.open(self.getFilePath(), "r")
    local tbl = textutils.unserialize(file.readAll())
    if tbl == nil then tbl = {} end
    tbl[key] = value
    file.close()
    
    file = fs.open(self.getFilePath(), "w")
    file.write(textutils.serialize(tbl))
    file.close()
  end
  
  return self
end