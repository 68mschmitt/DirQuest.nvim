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
  
  M.current_world = world.generate_world(width, height - 4)
  
  local px, py = player.get_position()
  local sprite = player.get_sprite()
  
  for i, line in ipairs(sprite) do
    local sprite_y = py + i - 1
    if sprite_y > 0 and sprite_y <= M.current_world.height then
      for j = 1, #line do
        local sprite_x = px + j - 1
        if sprite_x > 0 and sprite_x <= M.current_world.width then
          M.current_world.grid[sprite_y][sprite_x] = line:sub(j, j)
        end
      end
    end
  end
  
  local scroll_offset = 0
  if px > width - 20 then
    scroll_offset = px - (width - 20)
  end
  
  local lines = {}
  table.insert(lines, "")
  table.insert(lines, "  📁 " .. game.state.current_dir)
  table.insert(lines, "")
  
  for y = 1, M.current_world.height do
    local line = ""
    for x = 1, width do
      local world_x = x + scroll_offset
      if world_x > 0 and world_x <= M.current_world.width then
        line = line .. (M.current_world.grid[y][world_x] or " ")
      else
        line = line .. " "
      end
    end
    table.insert(lines, line)
  end
  
  table.insert(lines, "")
  table.insert(lines, "  Controls: hjkl = move | <CR> = interact | - = parent | q = quit")

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
    "  ║                      DirQuest v0.4.0                     ║",
    "  ║                                                          ║",
    "  ║            Navigate your filesystem as a game            ║",
    "  ║                                                          ║",
    "  ╚══════════════════════════════════════════════════════════╝",
    "",
    "",
    "  Welcome to DirQuest!",
    "",
    "  This is a side-scrolling file explorer game for Neovim.",
    "",
    "  Controls:",
    "    hjkl       - Move player",
    "    <CR>       - Interact with directories/files",
    "    q / <Esc>  - Quit",
    "",
    "  Phase 4: Simple World Generation",
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
