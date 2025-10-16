local M = {}

local renderer = require('dirquest.renderer')

M.version = "0.1.0"

local state = {
  buffer = nil,
  window = nil,
}

function M.start()
  if state.buffer and vim.api.nvim_buf_is_valid(state.buffer) then
    vim.api.nvim_buf_delete(state.buffer, { force = true })
  end

  state.buffer = renderer.create_buffer()
  state.window = vim.api.nvim_get_current_win()

  renderer.render_welcome(state.buffer)

  M.setup_keymaps(state.buffer)
end

function M.setup_keymaps(buffer)
  local opts = { noremap = true, silent = true, buffer = buffer }

  vim.keymap.set('n', 'q', function()
    M.close()
  end, opts)

  vim.keymap.set('n', '<Esc>', function()
    M.close()
  end, opts)
end

function M.close()
  if state.buffer and vim.api.nvim_buf_is_valid(state.buffer) then
    vim.api.nvim_buf_delete(state.buffer, { force = true })
  end
  state.buffer = nil
  state.window = nil
end

function M.setup(opts)
  opts = opts or {}
end

return M
