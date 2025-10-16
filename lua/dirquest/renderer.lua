local M = {}

local game = require('dirquest.game')
local player = require('dirquest.player')

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
  
  local world = {}
  for y = 1, height do
    world[y] = {}
    for x = 1, width do
      world[y][x] = " "
    end
  end
  
  local header_height = 3
  
  for x = 1, width do
    if header_height < height then
      world[header_height][x] = "="
    end
  end
  
  local px, py = player.get_position()
  local sprite = player.get_sprite()
  
  for i, line in ipairs(sprite) do
    local sprite_y = py + i - 1
    if sprite_y > 0 and sprite_y <= height then
      for j = 1, #line do
        local sprite_x = px + j - 1
        if sprite_x > 0 and sprite_x <= width then
          world[sprite_y][sprite_x] = line:sub(j, j)
        end
      end
    end
  end
  
  local lines = {}
  table.insert(lines, "")
  table.insert(lines, "  📁 " .. game.state.current_dir)
  table.insert(lines, "")
  
  for y = 4, height do
    local line = ""
    for x = 1, width do
      line = line .. (world[y][x] or " ")
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
    "  ║                      DirQuest v0.3.0                     ║",
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
    "    q / <Esc>  - Quit",
    "",
    "  Phase 3: Player Sprite and Movement",
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
