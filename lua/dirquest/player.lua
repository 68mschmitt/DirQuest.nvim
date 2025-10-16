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

    if world and world.collision_rects then
        local sprite = M.state.sprite
        local sprite_width = #sprite[1]
        local sprite_height = #sprite
        
        local player_rect = {
            x = x,
            y = y,
            width = sprite_width,
            height = sprite_height
        }
        
        for _, collision_rect in ipairs(world.collision_rects) do
            if collision_rect.type == "ground" then
                if direction == "down" then
                    if M.rects_overlap(player_rect, collision_rect) then
                        return false
                    end
                end
            elseif collision_rect.type == "structure" then
                if M.rects_overlap(player_rect, collision_rect) then
                    return false
                end
            end
        end
    end

    return true
end

function M.rects_overlap(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
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
