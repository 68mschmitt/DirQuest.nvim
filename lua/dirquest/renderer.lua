local M = {}

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
