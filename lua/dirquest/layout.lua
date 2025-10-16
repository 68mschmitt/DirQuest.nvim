local persist = require("memory_maze.persist")
local state   = require("memory_maze.state")

local M = {}

-- Build a grid room layout with walls; place parent exit and child items.
function M.build_room(dir, items, meta)
  -- Room size / viewport (odd dims to center player nicely)
  local W, H = 41, 21

  -- Occupancy grid
  local grid = {}
  for y=1,H do
    grid[y] = {}
    for x=1,W do
      grid[y][x] = "🟩"  -- floor
    end
  end
  -- Walls
  for x=1,W do grid[1][x]="🧱"; grid[H][x]="🧱" end
  for y=1,H do grid[y][1]="🧱"; grid[y][W]="🧱" end

  -- The parent exit (top-middle)
  local exit_x, exit_y = math.ceil(W/2), 2
  grid[exit_y][exit_x] = "⬆️"

  -- Load persisted coords/pins
  local coords = meta.items or {}
  local pins   = meta.pins or {}

  -- Helper to see if cell is free
  local function free(x,y)
    if x<=2 or x>=W-1 or y<=2 or y>=H-1 then return false end
    return grid[y][x] == "🟩"
  end

  -- Deterministic slotting spiral from center
  local cx, cy = math.ceil(W/2), math.ceil(H/2)+2
  local function nearest_free()
    if free(cx,cy) then return cx,cy end
    local r=1
    while r < 30 do
      for dx=-r,r do
        for dy=-r,r do
          local x,y = cx+dx, cy+dy
          if free(x,y) then return x,y end
        end
      end
      r=r+1
    end
    return cx,cy
  end

  -- Place items
  local tab = {}   -- id -> entity
  local list = {}  -- array of entities for drawing order
  local seen = {}

  -- Build/restore coords for each FS item
  for _,it in ipairs(items) do
    local id = it.path
    local pos = coords[id]
    local x,y
    if pos and free(pos.x, pos.y) then
      x,y = pos.x, pos.y
    else
      x,y = nearest_free()
      coords[id] = { x=x, y=y }
    end
    local ch = it.is_dir and "📁" or "📄"
    grid[y][x] = ch
    local e = {
      id = id,
      name = it.name,
      path = it.path,
      is_dir = it.is_dir,
      x = x, y = y,
      ch = ch,
      pin = pins[id], -- optional user pin text
    }
    tab[id] = e
    table.insert(list, e)
    seen[id]=true
  end

  -- Clean up stale entries in meta
  for id,_ in pairs(coords) do
    if not seen[id] then coords[id]=nil; pins[id]=nil end
  end
  persist.save(dir, { items = coords, pins = pins })

  -- Player spawn: near center; avoid collision
  local px, py = cx, cy
  if not free(px,py) then
    px, py = nearest_free()
  end

  -- Room object for state
  local room = {
    dir   = dir,
    W = W, H = H,
    grid = grid,
    exit = { x=exit_x, y=exit_y },
    entities = list,
    entities_by_id = tab,
    coords = coords,
    pins = pins,
    player = { x=px, y=py, ch="🧍" },
  }

  return room
end

return M
