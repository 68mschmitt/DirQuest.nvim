local M = {}

local game = require('dirquest.game')

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
    "  ║                      DirQuest v0.1.0                     ║",
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
    "    q / <Esc>  - Quit",
    "",
    "  Phase 1: Basic Buffer and Plugin Infrastructure",
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
