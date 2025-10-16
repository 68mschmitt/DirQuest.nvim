local state    = require("memory_maze.state")
local fs       = require("memory_maze.fs")
local layout   = require("memory_maze.layout")
local persist  = require("memory_maze.persist")
local renderer = require("memory_maze.renderer")
local ui       = require("memory_maze.ui")

local M = {}

local function move(dx, dy)
  local room = state.room
  local nx, ny = room.player.x + dx, room.player.y + dy
  -- walls
  if nx <= 1 or nx >= room.W or ny <= 1 or ny >= room.H then return end
  if room.grid[ny][nx] == "🧱" then return end
  room.player.x, room.player.y = nx, ny
  renderer.draw()
end

local function entity_at_player()
  local room = state.room
  for _,e in ipairs(room.entities) do
    if e.x == room.player.x and e.y == room.player.y then
      return e
    end
  end
  -- standing on exit?
  if room.player.x == room.exit.x and room.player.y == room.exit.y then
    return { is_exit = true }
  end
  return nil
end

local function open_current()
  local room = state.room
  local e = entity_at_player()
  if not e then return end
  if e.is_exit then
    local parent = vim.fn.fnamemodify(room.dir, ":h")
    if parent == room.dir then
      ui.message("Already at filesystem root")
      return
    end
    state.cwd = parent
    local items = fs.scan_dir(parent)
    local meta  = persist.load(parent)
    state.room  = layout.build_room(parent, items, meta)
    renderer.draw()
    return
  end
  if e.is_dir then
    state.cwd = e.path
    local items = fs.scan_dir(e.path)
    local meta  = persist.load(e.path)
    state.room  = layout.build_room(e.path, items, meta)
    renderer.draw()
  else
    -- open file
    vim.cmd("edit " .. vim.fn.fnameescape(e.path))
  end
end

local function peek_current()
  local e = entity_at_player()
  if not e or e.is_dir or e.is_exit then return end
  ui.preview_file(e.path)
end

local function toggle_pin()
  local room = state.room
  local e = entity_at_player()
  if not e or e.is_exit then return end
  local cur = room.pins[e.id]
  local new = vim.fn.input("Pin/label (blank to clear): ", cur or "")
  if new == "" then new = nil end
  room.pins[e.id] = new
  persist.save(room.dir, { items = room.coords, pins = room.pins })
  if new then
    ui.message(("Pinned %s: %s"):format(e.name, new))
  else
    ui.message(("Cleared pin for %s"):format(e.name))
  end
end

local function rescan()
  local room = state.room
  local items = fs.scan_dir(room.dir)
  local meta  = persist.load(room.dir)
  state.room  = layout.build_room(room.dir, items, meta)
  renderer.draw()
end

function M.bind_keys()
  local buf = state.buf
  local opts = { noremap = true, silent = true, nowait = true, buffer = buf }

  vim.keymap.set("n", "h", function() move(-1,0) end, opts)
  vim.keymap.set("n", "l", function() move(1,0)  end, opts)
  vim.keymap.set("n", "k", function() move(0,-1) end, opts)
  vim.keymap.set("n", "j", function() move(0,1)  end, opts)

  vim.keymap.set("n", "<CR>", open_current, opts)
  vim.keymap.set("n", "p",    peek_current, opts)
  vim.keymap.set("n", "t",    toggle_pin,   opts)
  vim.keymap.set("n", "r",    rescan,       opts)
  vim.keymap.set("n", "q",    function() vim.api.nvim_buf_delete(buf, { force = true }) end, opts)
end

return M
