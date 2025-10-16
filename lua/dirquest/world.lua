local M = {}

local ascii_art = require('dirquest.ascii_art')
local game = require('dirquest.game')

function M.generate_world(width, height)
  local world = {
    width = width,
    height = height,
    border = {
      top = 4,
      bottom = 3,
      left = 4,
      right = 4
    },
    grid = {},
    locations = {},
    objects = {},
    collision_rects = {}
  }
  
  world.playable_area = {
    x_start = world.border.left,
    y_start = world.border.top,
    x_end = world.width - world.border.right - 1,
    y_end = world.height - world.border.bottom - 1,
    width = world.width - world.border.left - world.border.right,
    height = world.height - world.border.top - world.border.bottom
  }
  
  for y = 1, height do
    world.grid[y] = {}
    for x = 1, width do
      world.grid[y][x] = " "
    end
  end
  
  M.add_border_collision(world)
  
  if game.state.items then
    M.layout_locations(world)
    M.place_files(world)
  end
  
  return world
end

function M.add_border_collision(world)
  table.insert(world.collision_rects, {
    x = 0,
    y = 0,
    width = world.width,
    height = world.border.top,
    type = "border"
  })
  
  table.insert(world.collision_rects, {
    x = 0,
    y = world.height - world.border.bottom + 1,
    width = world.width,
    height = world.border.bottom,
    type = "border"
  })
  
  table.insert(world.collision_rects, {
    x = 0,
    y = 0,
    width = world.border.left,
    height = world.height,
    type = "border"
  })
  
  table.insert(world.collision_rects, {
    x = world.width - world.border.right + 1,
    y = 0,
    width = world.border.right,
    height = world.height,
    type = "border"
  })
end

function M.layout_locations(world)
  local directories = game.state.items.directories
  if not directories or #directories == 0 then return end
  
  local num_dirs = math.min(#directories, 12)
  local cols = math.ceil(math.sqrt(num_dirs))
  local rows = math.ceil(num_dirs / cols)
  
  local h_spacing = math.floor(world.playable_area.width / (cols + 1))
  local v_spacing = math.floor(world.playable_area.height / (rows + 1))
  
  local idx = 1
  for row = 1, rows do
    for col = 1, cols do
      if idx > num_dirs then break end
      
      local dir = directories[idx]
      local size = 0
      local is_hidden = dir.name:sub(1, 1) == "."
      
      if dir.path then
        local items = require('dirquest.filesystem').read_directory(dir.path)
        if items then
          size = #items.directories + #items.files
        end
      end
      
      local art, entrance_offset = ascii_art.get_directory_art(dir.name, size, is_hidden)
      
      local art_width = vim.fn.strwidth(art[1])
      
      local x = world.playable_area.x_start + (col * h_spacing) - math.floor(art_width / 2)
      local y = world.playable_area.y_start + (row * v_spacing) - math.floor(#art / 2)
      
      x = math.max(world.playable_area.x_start, math.min(x, world.playable_area.x_end - art_width))
      y = math.max(world.playable_area.y_start, math.min(y, world.playable_area.y_end - #art))
      
      local art_width = vim.fn.strwidth(art[1])
      
      local location = {
        name = dir.name,
        path = dir.path,
        x = x,
        y = y,
        width = art_width,
        height = #art,
        art = art,
        is_directory = true,
        entrance = entrance_offset and {
          x = x + entrance_offset.x - 1,
          y = y + entrance_offset.y - 1
        } or nil
      }
      
      M.draw_location(world, location)
      table.insert(world.locations, location)
      
      table.insert(world.collision_rects, {
        x = location.x,
        y = location.y,
        width = location.width,
        height = location.height,
        type = "structure",
        object = location
      })
      
      idx = idx + 1
    end
  end
end

function M.draw_location(world, location)
  for i, line in ipairs(location.art) do
    local y = location.y + i - 1
    if y >= world.playable_area.y_start and y <= world.playable_area.y_end then
      local x = location.x
      local char_idx = 1
      while char_idx <= #line do
        local byte = line:byte(char_idx)
        local char_len
        if byte < 128 then
          char_len = 1
        elseif byte < 224 then
          char_len = 2
        elseif byte < 240 then
          char_len = 3
        else
          char_len = 4
        end
        
        if x >= world.playable_area.x_start and x <= world.playable_area.x_end then
          local char = line:sub(char_idx, char_idx + char_len - 1)
          world.grid[y][x] = char
        end
        
        char_idx = char_idx + char_len
        x = x + vim.fn.strwidth(line:sub(char_idx - char_len, char_idx - 1))
      end
    end
  end
end

function M.place_files(world)
  local files = game.state.items.files
  if not files or #files == 0 then return end
  
  local max_files = math.min(#files, 20)
  
  for i = 1, max_files do
    local file = files[i]
    local placed = false
    local attempts = 0
    
    while not placed and attempts < 100 do
      local x = math.random(world.playable_area.x_start, world.playable_area.x_end - 1)
      local y = math.random(world.playable_area.y_start, world.playable_area.y_end - 1)
      
      if not M.has_collision_at(world, x, y) then
        local sprite = ascii_art.get_file_sprite(file.name)
        local obj = {
          name = file.name,
          path = file.path,
          x = x,
          y = y,
          sprite = sprite,
          interaction_radius = 1,
          is_directory = false
        }
        
        M.draw_object(world, obj)
        table.insert(world.objects, obj)
        placed = true
      end
      
      attempts = attempts + 1
    end
  end
end

function M.has_collision_at(world, x, y)
  for _, rect in ipairs(world.collision_rects) do
    if x >= rect.x and x < rect.x + rect.width and
       y >= rect.y and y < rect.y + rect.height then
      return true
    end
  end
  
  for _, obj in ipairs(world.objects) do
    if x == obj.x and y == obj.y then
      return true
    end
  end
  
  return false
end

function M.draw_object(world, obj)
  if obj.y >= world.playable_area.y_start and obj.y <= world.playable_area.y_end and
     obj.x >= world.playable_area.x_start and obj.x <= world.playable_area.x_end then
    world.grid[obj.y][obj.x] = obj.sprite
  end
end

function M.get_object_at(world, x, y)
  for _, location in ipairs(world.locations) do
    if x >= location.x and x < location.x + location.width and
       y >= location.y and y < location.y + location.height then
      return location
    end
  end
  
  for _, obj in ipairs(world.objects) do
    if x == obj.x and y == obj.y then
      return obj
    end
  end
  
  return nil
end

function M.get_nearby_interactive(world, x, y, range)
  range = range or 1
  
  for _, location in ipairs(world.locations) do
    if location.entrance then
      local dx = math.abs(x - location.entrance.x)
      local dy = math.abs(y - location.entrance.y)
      if dx <= range and dy <= range then
        return location, "entrance"
      end
    end
  end
  
  for _, obj in ipairs(world.objects) do
    local dx = math.abs(x - obj.x)
    local dy = math.abs(y - obj.y)
    if dx <= range and dy <= range then
      return obj, "file"
    end
  end
  
  return nil, nil
end

return M
