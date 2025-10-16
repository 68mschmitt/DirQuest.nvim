local M = {}

M.default_sprite = {
  " o ",
  "/|\\"
}

M.state = {
  x = 5,
  y = 5,
  sprite = M.default_sprite
}

function M.init(x, y, sprite)
  M.state.x = x or 5
  M.state.y = y or 5
  M.state.sprite = sprite or M.default_sprite
end

function M.move(direction, world_width, world_height, world)
  local new_x = M.state.x
  local new_y = M.state.y
  
  if direction == "left" then
    new_x = new_x - 1
  elseif direction == "right" then
    new_x = new_x + 1
  elseif direction == "up" then
    new_y = new_y - 1
  elseif direction == "down" then
    new_y = new_y + 1
  end
  
  if M.can_move_to(new_x, new_y, world_width, world_height, world, direction) then
    M.state.x = new_x
    M.state.y = new_y
    return true
  end
  
  return false
end

function M.can_move_to(x, y, world_width, world_height, world, direction)
  if x < 0 or y < 0 then
    return false
  end
  
  if world_width and x >= world_width then
    return false
  end
  
  if world_height and y >= world_height then
    return false
  end
  
  if world and world.grid then
    local sprite = M.state.sprite
    for i = 1, #sprite do
      local sprite_line = sprite[i]
      for j = 1, #sprite_line do
        local check_x = x + j - 1
        local check_y = y + i - 1
        
        if check_y >= 1 and check_y <= world_height and check_x >= 1 and check_x <= world_width then
          local cell = world.grid[check_y][check_x]
          
          if cell == "=" then
            if direction == "down" then
              return false
            end
          elseif cell == "|" or cell == "_" or cell == "-" then
            return false
          end
        end
      end
    end
  end
  
  return true
end

function M.get_position()
  return M.state.x, M.state.y
end

function M.set_position(x, y)
  M.state.x = x
  M.state.y = y
end

function M.get_sprite()
  return M.state.sprite
end

function M.reset()
  M.state.x = 5
  M.state.y = 5
  M.state.sprite = M.default_sprite
end

return M
