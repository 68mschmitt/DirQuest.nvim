local M = {}

local filesystem = require('dirquest.filesystem')

M.state = {
  current_dir = nil,
  items = nil,
  buffer = nil,
  window = nil,
  selected_line = 1,
}

function M.init(starting_dir)
  M.state.current_dir = starting_dir or vim.loop.cwd()
  M.load_directory(M.state.current_dir)
end

function M.load_directory(path)
  local items, err = filesystem.read_directory(path)
  if not items then
    vim.notify("Error: " .. (err or "Cannot read directory"), vim.log.levels.ERROR)
    return false
  end
  
  M.state.current_dir = path
  M.state.items = items
  M.state.selected_line = 1
  return true
end

function M.get_item_at_line(line)
  if not M.state.items then return nil end
  
  local total_dirs = #M.state.items.directories
  local total_files = #M.state.items.files
  
  if line <= total_dirs then
    return M.state.items.directories[line]
  elseif line <= total_dirs + total_files then
    return M.state.items.files[line - total_dirs]
  end
  
  return nil
end

function M.navigate_into(item)
  if item and item.is_directory then
    return M.load_directory(item.path)
  elseif item and not item.is_directory then
    filesystem.open_file(item.path)
    return true
  end
  return false
end

function M.go_parent()
  local parent = filesystem.get_parent_directory(M.state.current_dir)
  if parent and parent ~= M.state.current_dir then
    return M.load_directory(parent)
  end
  return false
end

function M.reset()
  M.state.current_dir = nil
  M.state.items = nil
  M.state.buffer = nil
  M.state.window = nil
  M.state.selected_line = 1
end

return M
