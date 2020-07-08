local function loadApis(path)
  if fs.isDir(path) then
    for k, v in pairs(fs.list(path)) do
      loadApis(path.."/"..v)
    end
  else
    Logger.log("Loading "..path)
    local loaded = os.loadAPI(path)
    if loaded ~= nil then
      Logger.log("Successfully loaded "..path)
    else
      Logger.log("Error: failed to load "..path)
    end
  end
end

local ApiFolders = {
  "API"
}

local programPath = shell.dir()

dofile(programPath.."/API/Logger.lua")

Logger.ENABLED = true
Logger.FILE_PATH = programPath
Logger.clear()
Logger.log("---------Program started---------")

for k, v in pairs(ApiFolders) do
  loadApis(programPath.."/"..v)
end

local Program = Bedrock:Initialise(programPath)

local sharedPreferences = SharedPreferences.SharedPreferences(Program)

Program.sharedPreferences = sharedPreferences

sharedPreferences:edit("firstRun", false)

Program:LoadView("main")
Program:Run()