local programPath = shell.dir()
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
  if fs.isDir(path) and not isBlacklisted(path, blacklist) then
    for k, v in pairs(fs.list(path)) do
      loadApis(path.."/"..v, loadMethod, blacklist)
    end
  else
    if not isBlacklisted(path, blacklist) then
      totalApis = totalApis + 1
      Logger.log("Loading "..path)
      local loaded = loadMethod(path)
      if loaded ~= false then
        loadedApis = loadedApis + 1
        Logger.log("Successfully loaded "..path)
      else
        Logger.log("Error: failed to load "..path)
      end
    end
  end
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

for k, v in pairs(ApiFolders) do
  local path = v[1]
  local loadMethod = v[2]
  loadApis(programPath.."/"..path, loadMethod, apiNoLoad)
end
Logger.log("Loaded "..loadedApis.."/"..totalApis.." APIs")

local program = Bedrock:Initialise(programPath)

program.sharedPreferences = SharedPreferences(program)
program.sceneManager = SceneManager(program)
program.projectManager = ProjectManager(program)

program.sharedPreferences.edit("firstRun", false)

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
  
  program.sceneManager.setScene(MainMenuScene(program))
  program.projectManager.open(Project("", "Test"))
end)