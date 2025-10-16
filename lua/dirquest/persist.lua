local M = {}
local json = vim.json or require("vim.json")

local function meta_path(dir)
  return dir .. "/.memory_maze.json"
end

function M.load(dir)
  local fp = meta_path(dir)
  local f = io.open(fp, "r")
  if not f then return { items = {}, pins = {} } end
  local ok, data = pcall(function()
    local content = f:read("*a")
    f:close()
    return json.decode(content)
  end)
  if ok and type(data) == "table" then
    data.items = data.items or {}
    data.pins  = data.pins  or {}
    return data
  end
  return { items = {}, pins = {} }
end

function M.save(dir, data)
  local fp = meta_path(dir)
  local f = io.open(fp, "w")
  if not f then return end
  f:write((vim.json or require("vim.json")).encode(data))
  f:close()
end

return M
