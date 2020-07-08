ENABLED = false

function clear()
  fs.delete("Pineapple-Studio/log.txt")
end

function log(txt)
  if not ENABLED then return end
  
  local logFile = fs.open(shell.dir().."/log.txt", "a")
  logFile.write("["..os.time().."] : "..txt.."\n")
  logFile.flush()
  logFile.close()
end