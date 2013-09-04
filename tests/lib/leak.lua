local leak={}
local special={}

function leak.track(var)
  return setmetatable({[special]=var},{__mode="v"})
end

function leak.find(self)
  collectgarbage()
  collectgarbage()
  assert(type(self)=="table")
  
  local env = { seen = {}, unscanned = {}, target = self[special] }
  self[special] = nil

  if not env.target then
    return true
  end
   
  local function traverse(from, to, how, name)
    if to == env or env.seen[to] then return end
    env.seen[to] = {from = from, to = to, how = how, name = name}
    table.insert(env.unscanned,to)
  end

  --initialize roots
  traverse(nil,"_G","isname")
  traverse(nil,_G,"value","_G")
  traverse(nil,debug.getregistry(),"value","$registry")

  for i=2, math.huge do
    local info = debug.getinfo(i, "f") 
    if not info then break end 
    for j=1, math.huge do
      local n, v = debug.getlocal(i, j)
      if not n then break end
      traverse(nil, n, "isname", nil)
      traverse(nil, v, "local", n)
     end
  end

  local function pathstring(f)
    local node = env.seen[f]
    assert(node)
    local from = node.from and pathstring(node.from)
    local function tablekey(e)
      local fmt = type(e) == "string" and (e:match("[%a_][%w_]*") and ".%s" or '["%s"]') or "[%s]"
      return fmt:format(tostring(e))
    end
    if     "isname" == node.how then
      from = from or "$locals"
      string.format("%s.$name%s",from,tablekey(node.to))
    elseif "local" == node.how then
      return string.format("$locals.%s",node.name)
    elseif "value" == node.how then
      if not from then return node.name end
      return from..tablekey(node.name)
    elseif "key" == node.how then
      return string.format("%s.$keys%s",from,tablekey(node.to))
    elseif "upvalue" == node.how then
      return string.format("%s.$upvalue.%s",from,node.name)
    elseif "environment" == node.how then
      return string.format("%s.$environment",from)
    elseif "ismetatable" == node.how then
      return string.format("%s.$metatable",from)
    end
  end
  while #env.unscanned > 0 do
    local obj = table.remove(env.unscanned)
    if obj == env.target then
      return false, pathstring(obj)
    end
    local t = type(obj)
    if t == "string" or t == "number" or t == "boolean" then
      --pass
    elseif "table" == t then
      for key, value in pairs(obj) do
        traverse(obj, key, "key", nil)
        traverse(obj, value, "value", key)
      end
      local mtable = debug.getmetatable(obj)
      if mtable then traverse(obj, mtable, "ismetatable", nil) end 
    elseif "function" == t then
      for i = 1, math.huge do
        local n, v = debug.getupvalue(obj, i)
        if not n then break end -- when there is no upvalues
        traverse(obj, n, "isname", nil)
        traverse(obj, v, "upvalue", n)
      end
      local fenv = debug.getfenv(obj)
      traverse(obj, fenv, "environment", nil)
    elseif "userdata" == t or "cdata" == t then
      local mtable = debug.getmetatable(obj)
      if mtable then traverse(obj, mtable, "ismetatable", nil) end
      local fenv = debug.getfenv(obj)
      if fenv then traverse(obj, fenv, "environment", nil) end
    else
      print("warning! ignoring unknown object type: ",t)
    end
  end
  return false, "error! failed to find the path to object"
end
return leak


