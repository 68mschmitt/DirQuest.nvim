local M = {}

local renderer = require('dirquest.renderer')
local game = require('dirquest.game')
local player = require('dirquest.player')

M.version = "0.3.0"

function M.start(path)
  if game.state.buffer and vim.api.nvim_buf_is_valid(game.state.buffer) then
    vim.api.nvim_buf_delete(game.state.buffer, { force = true })
  end

  local starting_dir = path or vim.loop.cwd()
  game.init(starting_dir)
  player.init()

  game.state.buffer = renderer.create_buffer()
  game.state.window = vim.api.nvim_get_current_win()

  renderer.render_world(game.state.buffer)

  M.setup_keymaps(game.state.buffer)
end

function M.setup_keymaps(buffer)
  local opts = { noremap = true, silent = true, buffer = buffer }

  vim.keymap.set('n', 'q', function()
    M.close()
  end, opts)

  vim.keymap.set('n', '<Esc>', function()
    M.close()
  end, opts)

  vim.keymap.set('n', 'h', function()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    player.move("left", width, height)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', 'j', function()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    player.move("down", width, height)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', 'k', function()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    player.move("up", width, height)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', 'l', function()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    player.move("right", width, height)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', '<CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1]
    
    local header_offset = 3
    local item_line = line - header_offset
    
    if item_line > 0 then
      local item = game.get_item_at_line(item_line)
      if item then
        if item.is_directory then
          game.navigate_into(item)
          renderer.render_world(game.state.buffer)
        else
          game.navigate_into(item)
        end
      end
    end
  end, opts)

  vim.keymap.set('n', '-', function()
    if game.go_parent() then
      renderer.render_world(game.state.buffer)
    end
  end, opts)
end

function M.close()
  if game.state.buffer and vim.api.nvim_buf_is_valid(game.state.buffer) then
    vim.api.nvim_buf_delete(game.state.buffer, { force = true })
  end
  game.reset()
  player.reset()
end

function M.setup(opts)
  opts = opts or {}
  
  if opts.player_sprite then
    player.default_sprite = opts.player_sprite
  end
end

return M
