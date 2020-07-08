--ENABLED = false

Logger = {}

Logger.ENABLED = false
Logger.FILE_PATH = ""
Logger.FILE_NAME = "log.txt"

function Logger.clear()
  fs.delete("Pineapple-Studio/log.txt")
end

function Logger.log(txt)
  if not Logger.ENABLED then return end
  
  local logFile = fs.open(Logger.FILE_PATH.."/"..Logger.FILE_NAME, "a")
  logFile.write("["..os.time().."] : "..txt.."\n")
  logFile.flush()
  logFile.close()
end