local state = require("memory_maze.state")

local M = {}
local ns  = vim.api.nvim_create_namespace("memory_maze")

function M.status(text)
  local buf = state.buf
  if not buf then return end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
    virt_text = { { " " .. text .. " ", "NonText" } },
    virt_text_pos = "right_align",
  })
end

function M.message(msg)
  vim.notify("[MemoryMaze] " .. msg, vim.log.levels.INFO)
end

function M.preview_file(path)
  -- Try read file text
  local f = io.open(path, "r")
  if not f then
    M.message("Cannot open file for preview")
    return
  end
  local lines = {}
  for i=1,200 do
    local ln = f:read("*l"); if not ln then break end
    lines[#lines+1] = ln
  end
  f:close()

  -- Floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, (#lines>0) and lines or { "<empty>" })
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype  = vim.filetype.match({ filename = path }) or ""

  local cols = math.floor(vim.o.columns * 0.6)
  local rows = math.floor(vim.o.lines   * 0.6)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = cols, height = rows,
    row = math.floor((vim.o.lines-rows)/2),
    col = math.floor((vim.o.columns-cols)/2),
  })
  vim.keymap.set("n", "q", function() pcall(vim.api.nvim_win_close, win, true) end,
    { buffer = buf, nowait = true, silent = true })
end

return M
