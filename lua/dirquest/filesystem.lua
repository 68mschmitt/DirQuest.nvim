local M = {}

function M.read_directory(path)
  local items = {
    directories = {},
    files = {}
  }

  local handle = vim.loop.fs_scandir(path)
  if not handle then
    return nil, "Cannot read directory: " .. path
  end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end

    local full_path = path .. "/" .. name
    local item = {
      name = name,
      path = full_path,
      is_directory = (type == "directory")
    }

    if type == "directory" then
      table.insert(items.directories, item)
    elseif type == "file" then
      table.insert(items.files, item)
    end
  end

  table.sort(items.directories, function(a, b)
    return a.name:lower() < b.name:lower()
  end)
  
  table.sort(items.files, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  return items
end

function M.is_directory(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == "directory"
end

function M.get_parent_directory(path)
  return vim.fn.fnamemodify(path, ":h")
end

function M.open_file(path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

function M.get_file_type(path)
  return vim.fn.fnamemodify(path, ":e")
end

return M
