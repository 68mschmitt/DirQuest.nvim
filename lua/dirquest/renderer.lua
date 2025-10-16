local state = require("memory_maze.state")
local ui    = require("memory_maze.ui")

local M = {}

function M.open_buffer()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_set_current_buf(state.buf)
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  state.buf = buf
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "memory_maze"
  vim.wo.wrap = false
  vim.api.nvim_buf_set_name(buf, "MemoryMaze")
end

local function empty_lines(h) local t={}; for _=1,h do t[#t+1]="" end; return t end

function M.draw()
  local room = state.room
  if not room then return end
  local buf = state.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end

  local lines = {}
  for y=1,room.H do
    local row = {}
    for x=1,room.W do
      row[#row+1] = room.grid[y][x]
    end
    lines[#lines+1] = table.concat(row)
  end

  -- Draw entities over tiles
  for _,e in ipairs(room.entities) do
    local L = lines[e.y]
    lines[e.y] = L:sub(1, e.x-1) .. e.ch .. L:sub(e.x+1)
  end

  -- Draw player
  local L = lines[room.player.y]
  lines[room.player.y] = L:sub(1, room.player.x-1) .. room.player.ch .. L:sub(room.player.x+1)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Statusline-ish hint
  ui.status(("cwd: %s | h/j/k/l: move | <CR>: open | p: peek | t: pin | r: rescan | q: quit"):format(room.dir))
end

return M
