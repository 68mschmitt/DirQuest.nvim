local fs       = require("memory_maze.fs")
local persist  = require("memory_maze.persist")
local layout   = require("memory_maze.layout")
local renderer = require("memory_maze.renderer")
local input    = require("memory_maze.input")
local state    = require("memory_maze.state")

local M = {}

function M.start(root)
  -- Root = cwd by default
  root = root or vim.loop.cwd()

  -- Initialize global game state
  state.reset()
  state.cwd = root

  -- Load dir items + persisted layout
  local items = fs.scan_dir(root)
  local meta  = persist.load(root)
  local room  = layout.build_room(root, items, meta)

  state.room = room
  renderer.open_buffer()
  renderer.draw()

  input.bind_keys()
end

return M
