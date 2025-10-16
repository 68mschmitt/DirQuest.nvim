local M = {}

local game = require('dirquest.game')
local player = require('dirquest.player')
local world = require('dirquest.world')

M.current_world = nil

function M.create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'buflisted', false)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  vim.api.nvim_buf_set_name(buf, 'DirQuest')

  vim.api.nvim_set_current_buf(buf)

  return buf
end

function M.render_world(buffer)
  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)
  
  if not M.current_world or M.current_world.width ~= width or M.current_world.height ~= height then
    M.current_world = world.generate_world(width, height)
  else
    for y = M.current_world.playable_area.y_start, M.current_world.playable_area.y_end do
      for x = M.current_world.playable_area.x_start, M.current_world.playable_area.x_end do
        local cell = M.current_world.grid[y][x]
        local is_player = (cell == player.get_sprite())
        local is_structure = false
        
        for _, loc in ipairs(M.current_world.locations) do
          if x >= loc.x and x < loc.x + loc.width and y >= loc.y and y < loc.y + loc.height then
            is_structure = true
            break
          end
        end
        
        local is_file = false
        for _, obj in ipairs(M.current_world.objects) do
          if x == obj.x and y == obj.y then
            is_file = true
            break
          end
        end
        
        if is_player and not is_structure then
          M.current_world.grid[y][x] = " "
        end
      end
    end
  end
  
  local px, py = player.get_position()
  
  if px < M.current_world.playable_area.x_start or px > M.current_world.playable_area.x_end or
     py < M.current_world.playable_area.y_start or py > M.current_world.playable_area.y_end then
    player.set_position(
      math.floor(M.current_world.playable_area.x_start + M.current_world.playable_area.width / 2),
      math.floor(M.current_world.playable_area.y_start + M.current_world.playable_area.height / 2)
    )
    px, py = player.get_position()
  end
  
  local player_sprite = player.get_sprite()
  if M.current_world.grid[py] and M.current_world.grid[py][px] then
    M.current_world.grid[py][px] = player_sprite
  end
  
  local lines = {}
  
  local nearby_obj, obj_type = world.get_nearby_interactive(M.current_world, px, py, 1)
  
  table.insert(lines, "┌" .. string.rep("─", width - 2) .. "┐")
  
  local path_line = "│ 📁 " .. game.state.current_dir
  local padding = width - vim.fn.strwidth(path_line) - 1
  table.insert(lines, path_line .. string.rep(" ", math.max(0, padding)) .. "│")
  
  local hint_line
  if nearby_obj and obj_type == "entrance" then
    hint_line = "│ <CR> to enter " .. nearby_obj.name
  elseif nearby_obj and obj_type == "file" then
    hint_line = "│ <CR> to open " .. nearby_obj.name
  else
    hint_line = "│ hjkl=move | <CR>=interact | -=parent | q=quit"
  end
  padding = width - vim.fn.strwidth(hint_line) - 1
  table.insert(lines, hint_line .. string.rep(" ", math.max(0, padding)) .. "│")
  
  table.insert(lines, "├" .. string.rep("─", width - 2) .. "┤")
  
  for y = M.current_world.playable_area.y_start, M.current_world.playable_area.y_end do
    local line_parts = {"│"}
    local current_width = 1
    
    for x = M.current_world.playable_area.x_start, M.current_world.playable_area.x_end do
      local cell = M.current_world.grid[y][x] or " "
      table.insert(line_parts, cell)
      current_width = current_width + vim.fn.strwidth(cell)
    end
    
    local padding_needed = width - current_width - 1
    table.insert(line_parts, string.rep(" ", math.max(0, padding_needed)))
    table.insert(line_parts, "│")
    
    table.insert(lines, table.concat(line_parts))
  end
  
  table.insert(lines, "├" .. string.rep("─", width - 2) .. "┤")
  
  local status_line = "│ Dirs: " .. #M.current_world.locations .. " | Files: " .. #M.current_world.objects
  padding = width - vim.fn.strwidth(status_line) - 1
  table.insert(lines, status_line .. string.rep(" ", math.max(0, padding)) .. "│")
  
  table.insert(lines, "└" .. string.rep("─", width - 2) .. "┘")

  vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
end

function M.render_directory(buffer)
  local lines = {}
  
  table.insert(lines, "")
  table.insert(lines, "  📁 " .. game.state.current_dir)
  table.insert(lines, "")

  if not game.state.items then
    table.insert(lines, "  [Error: Cannot read directory]")
  else
    local total_items = #game.state.items.directories + #game.state.items.files
    
    if total_items == 0 then
      table.insert(lines, "  [Empty directory]")
    else
      for _, dir in ipairs(game.state.items.directories) do
        table.insert(lines, "  [DIR]  " .. dir.name)
      end
      
      for _, file in ipairs(game.state.items.files) do
        table.insert(lines, "  [FILE] " .. file.name)
      end
    end
  end
  
  table.insert(lines, "")
  table.insert(lines, "  Controls: <CR> = open | - = parent | q = quit")

  vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
  
  vim.api.nvim_win_set_cursor(0, {4, 0})
end

function M.render_welcome(buffer)
  local lines = {
    "",
    "  ╔══════════════════════════════════════════════════════════╗",
    "  ║                                                          ║",
    "  ║                      DirQuest v0.6.0                     ║",
    "  ║                                                          ║",
    "  ║            Navigate your filesystem as a game            ║",
    "  ║                                                          ║",
    "  ╚══════════════════════════════════════════════════════════╝",
    "",
    "",
    "  Welcome to DirQuest!",
    "",
    "  This is a top-down file explorer game for Neovim.",
    "",
    "  Controls:",
    "    hjkl       - Move player (🚶)",
    "    <CR>       - Interact with directories/files",
    "    q / <Esc>  - Quit",
    "",
    "  Phase 6: Top-Down View Redesign",
    "",
  }

  vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
end

function M.clear(buffer)
  vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
  vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
end

return M
