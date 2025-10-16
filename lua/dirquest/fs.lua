local M = {}

-- Returns array of { name, path, is_dir, size, mtime }
function M.scan_dir(dir)
  local items = {}
  local fd = vim.loop.fs_scandir(dir)
  if not fd then return items end

  while true do
    local name, t = vim.loop.fs_scandir_next(fd)
    if not name then break end
    if name:sub(1,1) ~= "." or name == ".memory_maze.json" then
      local path = dir .. "/" .. name
      local stat = vim.loop.fs_stat(path) or {}
      table.insert(items, {
        name = name,
        path = path,
        is_dir = (t == "directory"),
        size = stat.size or 0,
        mtime = stat.mtime and stat.mtime.sec or 0,
      })
    end
  end

  table.sort(items, function(a,b)
    if a.is_dir ~= b.is_dir then return a.is_dir end
    return a.name:lower() < b.name:lower()
  end)

  return items
end

return M
