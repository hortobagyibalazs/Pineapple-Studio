local programPath = shell.dir()
local VERSION = 0.1

-- API loading functionality
local totalApis = 0
local loadedApis = 0

local function isBlacklisted(path, blacklist)
  for k, v in pairs(blacklist) do
    if k == path or v == path then
      return true
    end
  end
  
  return false
end

local function loadApis(path, loadMethod, blacklist)
  local results = {}
  
  if fs.isDir(path) and not isBlacklisted(path, blacklist) then
    for k, v in pairs(fs.list(path)) do
      table.insert(results, loadApis(path.."/"..v, loadMethod, blacklist))
    end
  else
    if not isBlacklisted(path, blacklist) then
      totalApis = totalApis + 1
      Logger.log("main: Loading "..path)
      local loaded = loadMethod(path)
      if loaded ~= false then
        loadedApis = loadedApis + 1
        if loaded ~= nil then
          table.insert(results, loaded)
        end
        Logger.log("main: Successfully loaded "..path)
      else
        Logger.log("main: Error: failed to load "..path)
      end
    end
  end
  
  return results
end

local ApiFolders = {
  {
    "API", os.loadAPI
  },
  {
    "Util", dofile
  },
  {
    "Scene", dofile
  },
  {
    "Extension", dofile
  }
}

local apiNoLoad = {
  programPath.."/Util/Logger"
}

dofile(programPath.."/Util/Logger")

Logger.ENABLED = true
Logger.FILE_PATH = programPath
Logger.clear()
Logger.log("---------Program started---------")

local extensions = {}

for k, v in pairs(ApiFolders) do
  local path = v[1]
  local loadMethod = v[2]
  local results = loadApis(programPath.."/"..path, loadMethod, apiNoLoad, {})
  
  if path == "Extension" and results then
    for k, v in pairs(results) do
      for i, extension in pairs(v) do
        if type(extension) == "table" then
          table.insert(extensions, extension)
        end
      end
    end
  end
end
Logger.log("main: Loaded "..loadedApis.."/"..totalApis.." APIs")

-- Initialize main services
local program = Bedrock:Initialise(programPath)
program.version = VERSION

program.sharedPreferences = SharedPreferences(program.ProgramPath.."/Config/preferences.lua")
program.sceneManager = SceneManager(program)
program.projectManager = ProjectManager(program)
program.extensionManager = ExtensionManager(program)
program.themeManager = ThemeManager(program)

for k, extension in pairs(extensions) do
  program.extensionManager.addExtension(extension)
end

program.sceneManager.onSceneChange = function(scene)
  program.extensionManager.notify()
end

program.sharedPreferences.read()
program.sharedPreferences.edit("firstRun", false)

local defaultTheme = "light"
local theme = program.sharedPreferences.getOrDefault("theme", defaultTheme)
program.themeManager.loadTheme(theme)
program.OnDraw = function(self)
  self.themeManager.applyTheme(self.View)
end

-- Enter program's main loop
program:Run(function()
  program.projectManager.addProjectChangeListener(function(project)
    if project ~= nil then
      program.sceneManager.setScene(ProjectViewScene(program))
    end
  end)
  
  --[[if program.sharedPreferences.getOrDefault("openLastProjectOnStartup", false) then
    local lastProject = program.sharedPreferences.getOrDefault("lastProject", nil)
    if lastProject then
      local project = Project(lastProject["Root"], lastProject["Name"])
      program.projectManager.open(project)
    end
  end]]
  
  --program.sceneManager.setScene(MainMenuScene(program))
  
  local project = Project("/System/Projects", "Appstore.program")
  program.projectManager.open(project)
end)