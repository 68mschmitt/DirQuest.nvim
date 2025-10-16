local M = {}

local renderer = require('dirquest.renderer')
local game = require('dirquest.game')
local player = require('dirquest.player')

M.version = "0.6.0"

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
    player.move("left", width, height, renderer.current_world)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', 'j', function()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    player.move("down", width, height, renderer.current_world)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', 'k', function()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    player.move("up", width, height, renderer.current_world)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', 'l', function()
    local width = vim.api.nvim_win_get_width(0)
    local height = vim.api.nvim_win_get_height(0)
    player.move("right", width, height, renderer.current_world)
    renderer.render_world(game.state.buffer)
  end, opts)

  vim.keymap.set('n', '<CR>', function()
    local px, py = player.get_position()
    
    if renderer.current_world then
      local obj, obj_type = require('dirquest.world').get_nearby_interactive(renderer.current_world, px, py, 2)
      
      if obj then
        if obj.is_directory then
          game.navigate_into(obj)
          player.set_position(5, 5)
          renderer.render_world(game.state.buffer)
        else
          require('dirquest.filesystem').open_file(obj.path)
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
