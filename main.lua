local function loadApis(path)
  if fs.isDir(path) then
    for k, v in pairs(fs.list(path)) do
      loadApis(path.."/"..v)
    end
  else
    Logger.log("Loading "..path)
    os.loadAPI(path)
    Logger.log("Successfully loaded "..path)
  end
end

local ApiFolders = {
  "API"
}

local programPath = shell.dir()

os.loadAPI(programPath.."/API/Logger.lua")
Logger.ENABLED = true
Logger.clear()
Logger.log("---------Program started---------")

for k, v in pairs(ApiFolders) do
  loadApis(programPath.."/"..v)
end

local Program = Bedrock:Initialise(programPath)
Program:LoadView("main")
Program:Run()
Logger.log("---------Program ended---------")