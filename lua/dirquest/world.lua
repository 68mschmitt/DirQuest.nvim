local M = {}

local ascii_art = require('dirquest.ascii_art')
local game = require('dirquest.game')

function M.generate_world(width, height)
  local total_dirs = 0
  if game.state.items and game.state.items.directories then
    total_dirs = #game.state.items.directories
  end
  
  local min_world_width = math.max(width, total_dirs * 30)
  
  local world = {
    width = min_world_width,
    height = height,
    grid = {},
    locations = {},
    objects = {},
    ground_level = height - 5,
    view_width = width
  }
  
  for y = 1, height do
    world.grid[y] = {}
    for x = 1, min_world_width do
      world.grid[y][x] = " "
    end
  end
  
  M.draw_ground(world)
  
  if game.state.items then
    M.layout_locations(world)
    M.place_files(world)
  end
  
  return world
end

function M.draw_ground(world)
  for x = 1, world.width do
    world.grid[world.ground_level][x] = "="
  end
end

function M.layout_locations(world)
  local directories = game.state.items.directories
  local x_offset = 5
  local spacing = 15
  
  for i, dir in ipairs(directories) do
    local size = 0
    if dir.path then
      local items = require('dirquest.filesystem').read_directory(dir.path)
      if items then
        size = #items.directories + #items.files
      end
    end
    
    local art = ascii_art.get_directory_art(dir.name, size)
    local location = {
      name = dir.name,
      path = dir.path,
      x = x_offset,
      y = world.ground_level - #art,
      width = #art[1],
      height = #art,
      art = art,
      is_directory = true
    }
    
    M.draw_location(world, location)
    table.insert(world.locations, location)
    
    x_offset = x_offset + location.width + spacing
    
    if x_offset >= world.width - 20 then
      break
    end
  end
end

function M.draw_location(world, location)
  for i, line in ipairs(location.art) do
    local y = location.y + i - 1
    if y > 0 and y <= world.height then
      for j = 1, #line do
        local x = location.x + j - 1
        if x > 0 and x <= world.width then
          world.grid[y][x] = line:sub(j, j)
        end
      end
    end
  end
end

function M.place_files(world)
  local files = game.state.items.files
  local x_offset = 5
  local file_y = world.ground_level - 1
  
  for i, file in ipairs(files) do
    if i > 10 then break end
    
    local sprite = ascii_art.get_file_sprite(file.name)
    local obj = {
      name = file.name,
      path = file.path,
      x = x_offset,
      y = file_y,
      sprite = sprite,
      is_directory = false
    }
    
    M.draw_object(world, obj)
    table.insert(world.objects, obj)
    
    x_offset = x_offset + #sprite[1] + 3
    
    if x_offset >= world.width - 10 then
      break
    end
  end
end

function M.draw_object(world, obj)
  for i, line in ipairs(obj.sprite) do
    local y = obj.y + i - 1
    if y > 0 and y <= world.height then
      for j = 1, #line do
        local x = obj.x + j - 1
        if x > 0 and x <= world.width then
          world.grid[y][x] = line:sub(j, j)
        end
      end
    end
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
    if x >= obj.x and x < obj.x + #obj.sprite[1] and
       y >= obj.y and y < obj.y + #obj.sprite then
      return obj
    end
  end
  
  return nil
end

return M
