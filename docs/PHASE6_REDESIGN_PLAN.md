# Phase 6: Top-Down View Redesign - Implementation Plan

## Overview

This document outlines the complete redesign of DirQuest from a side-scrolling game to a top-down exploration game. This is a **major architectural change** that affects every module.

## Design Goals

### Visual Paradigm Shift

**From (Phases 1-5)**: Side-scroller with ground
```
     ___    _____
    |   |  |     |     [F]
    | A |  |  B  |
    |___|  |_____|
  ==================
      o
     /|\
   (player)
```

**To (Phase 6+)**: Top-down bird's-eye view
```
┌──────────────────────────┐
│ 📁 /current/directory    │ ← HUD
│ Controls: hjkl=move      │
├──────────────────────────┤
│  ╔═══════╗               │
│  ║  src  ║    📄 file    │
│  ╚═══════╝               │ ← Playable Area
│                          │
│      🚶                  │
│    (player)              │
├──────────────────────────┤
│ Status info              │ ← Status
└──────────────────────────┘
```

## Key Changes

### 1. Player Sprite
- **Before**: Multi-line ASCII (`" o "` and `"/|\\"`)
- **After**: Single character emoji (`🚶`)
- **Dimensions**: 3×2 → 1×1
- **Animation**: Future support for directional emojis (🧍, 🚶, etc.)
- **Fallback**: Cursor or `●` for non-emoji terminals

### 2. World Layout
- **Before**: Horizontal side-scroller with ground at bottom
- **After**: Full-buffer top-down view with objects throughout
- **Distribution**: Objects spread across entire playable area
- **Ground**: Removed entirely (no gravity concept)
- **Borders**: Buffer has defined border for HUD/status

### 3. Directory Representation
- **Before**: Side-view buildings with varied heights
- **After**: Top-down boxes with uniform style
- **Style**: Box-drawing characters (`╔═╗╚═╝║`)
- **Entrances**: Standardized at bottom-center of each box
- **Sizes**: Still vary (small/medium/large) but as top-down boxes

### 4. File Sprites
- **Before**: Multi-character labels (`[L]`, `[T]`, etc.)
- **After**: Single emoji characters (`📜`, `📄`, `🐍`)
- **Interaction**: 1-tile radius around sprite (standardized)

### 5. Border System (NEW)
- **Top Border**: 3 lines for HUD (path, controls, prompts)
- **Bottom Border**: 2 lines for status info
- **Side Borders**: 2 columns each side (optional)
- **Playable Area**: Everything between borders
- **Collision**: Cannot move into border areas

## Implementation Steps

### Step 1: Define Border System

**File**: `lua/dirquest/world.lua`

```lua
-- Add to world structure
world.border = {
  top = 3,
  bottom = 2,
  left = 2,
  right = 2
}

-- Calculate playable area
world.playable_area = {
  x_start = world.border.left,
  y_start = world.border.top,
  x_end = world.width - world.border.right,
  y_end = world.height - world.border.bottom,
  width = world.width - world.border.left - world.border.right,
  height = world.height - world.border.top - world.border.bottom
}

-- Add border collision rectangles
table.insert(world.collision_rects, {
  x = 0, y = 0,
  width = world.width,
  height = world.border.top,
  type = "border"
})
-- Similar for other borders...
```

### Step 2: Update Player Sprite

**File**: `lua/dirquest/player.lua`

```lua
-- Change default sprite
M.default_sprite = "🚶"  -- Single character

-- Update state structure
M.state = {
  x = 5,
  y = 5,
  sprite = M.default_sprite,  -- Now a string, not array
  animation = {
    idle = "🧍",
    walk_up = "🚶",
    walk_down = "🚶",
    walk_left = "🚶",
    walk_right = "🚶"
  }
}

-- Update collision detection for 1x1 sprite
local player_rect = {
  x = x,
  y = y,
  width = 1,  -- Changed from sprite width
  height = 1  -- Changed from sprite height
}
```

### Step 3: Redesign Directory Templates

**File**: `lua/dirquest/ascii_art.lua`

```lua
M.directory_templates = {
  small = {
    art = {
      "╔═══════╗",
      "║ name  ║",
      "║       ║",
      "╚═══════╝"
    },
    entrance = { x = 4, y = 3 }  -- Bottom center
  },
  
  medium = {
    art = {
      "╔═══════════╗",
      "║   name    ║",
      "║           ║",
      "║           ║",
      "╚═══════════╝"
    },
    entrance = { x = 6, y = 4 }
  },
  
  large = {
    art = {
      "╔═══════════════╗",
      "║     name      ║",
      "║               ║",
      "║               ║",
      "║               ║",
      "╚═══════════════╝"
    },
    entrance = { x = 8, y = 5 }
  },
  
  hidden = {
    art = {
      "┌─────────┐",
      "│  .name  │",
      "│ (hide)  │",
      "└─────────┘"
    },
    entrance = { x = 5, y = 3 }
  }
}
```

### Step 4: Update File Sprites

**File**: `lua/dirquest/ascii_art.lua`

```lua
M.file_sprites = {
  lua = "📜",      -- Script scroll
  txt = "📄",      -- Text document
  md = "📝",       -- Markdown note
  js = "📘",       -- JavaScript book
  py = "🐍",       -- Python snake
  rb = "💎",       -- Ruby gem
  go = "🐹",       -- Go gopher
  rs = "🦀",       -- Rust crab
  java = "☕",     -- Java coffee
  cpp = "⚙️",      -- C++ gear
  c = "⚙️",        -- C gear
  png = "🖼️",      -- Image frame
  jpg = "🖼️",      -- Image frame
  gif = "🖼️",      -- Image frame
  json = "📋",     -- Data clipboard
  yaml = "📋",     -- Config clipboard
  xml = "📋",      -- Markup clipboard
  default = "📦"   -- Generic package
}

-- Interaction radius (standardized)
M.interaction_radius = 1
```

### Step 5: Rewrite World Layout

**File**: `lua/dirquest/world.lua`

```lua
function M.layout_locations(world)
  local directories = game.state.items.directories
  
  -- Calculate grid for distribution
  local num_dirs = #directories
  local cols = math.ceil(math.sqrt(num_dirs))
  local rows = math.ceil(num_dirs / cols)
  
  -- Calculate spacing
  local h_spacing = math.floor(world.playable_area.width / (cols + 1))
  local v_spacing = math.floor(world.playable_area.height / (rows + 1))
  
  -- Place directories in grid pattern
  local idx = 1
  for row = 1, rows do
    for col = 1, cols do
      if idx > num_dirs then break end
      
      local dir = directories[idx]
      local x = world.playable_area.x_start + (col * h_spacing)
      local y = world.playable_area.y_start + (row * v_spacing)
      
      -- Create location at calculated position
      -- ... (rest of location creation)
      
      idx = idx + 1
    end
  end
end

function M.place_files(world)
  local files = game.state.items.files
  
  -- Randomly distribute files in open spaces
  for i, file in ipairs(files) do
    local placed = false
    local attempts = 0
    
    while not placed and attempts < 50 do
      local x = math.random(world.playable_area.x_start, world.playable_area.x_end - 1)
      local y = math.random(world.playable_area.y_start, world.playable_area.y_end - 1)
      
      -- Check if position is free (no collision)
      if not M.has_collision_at(world, x, y) then
        local obj = {
          name = file.name,
          path = file.path,
          x = x,
          y = y,
          sprite = ascii_art.get_file_sprite(file.name),
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
```

### Step 6: Update Renderer

**File**: `lua/dirquest/renderer.lua`

```lua
function M.render_world(buffer)
  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)
  
  -- Generate world with borders
  M.current_world = world.generate_world(width, height)
  
  -- Render borders first
  local lines = {}
  
  -- Top border (HUD)
  table.insert(lines, "┌" .. string.rep("─", width - 2) .. "┐")
  table.insert(lines, "│ 📁 " .. game.state.current_dir .. string.rep(" ", width - 5 - #game.state.current_dir) .. "│")
  
  -- Get interaction hints
  local px, py = player.get_position()
  local nearby_obj, obj_type = world.get_nearby_interactive(M.current_world, px, py, 1)
  local hint = nearby_obj and ("│ <CR> to " .. (obj_type == "entrance" and "enter " or "open ") .. nearby_obj.name) or ""
  table.insert(lines, hint .. string.rep(" ", width - #hint - 1) .. "│")
  
  table.insert(lines, "├" .. string.rep("─", width - 2) .. "┤")
  
  -- Draw world grid with player
  local player_sprite = player.get_sprite()
  for y = M.current_world.playable_area.y_start, M.current_world.playable_area.y_end do
    local line = "│ "
    for x = M.current_world.playable_area.x_start, M.current_world.playable_area.x_end do
      if x == px and y == py then
        line = line .. player_sprite
      else
        line = line .. (M.current_world.grid[y][x] or " ")
      end
    end
    line = line .. " │"
    table.insert(lines, line)
  end
  
  -- Bottom border (Status)
  table.insert(lines, "├" .. string.rep("─", width - 2) .. "┤")
  table.insert(lines, "│ hjkl=move | <CR>=interact | -=parent | q=quit" .. string.rep(" ", width - 50) .. "│")
  table.insert(lines, "└" .. string.rep("─", width - 2) .. "┘")
  
  -- Write to buffer
  vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
end
```

### Step 7: Remove Ground System

**Files**: `lua/dirquest/world.lua`, `lua/dirquest/player.lua`

- Remove `ground_level` from world structure
- Remove `draw_ground()` function
- Remove ground collision checks
- Update collision to only check borders and structures

### Step 8: Test and Validate

Create comprehensive tests for:
- Border collision
- Player single-character rendering
- Top-down object distribution
- Interaction radius consistency
- No ground/gravity artifacts

## Migration Notes

### Breaking Changes
- Player sprite format changed (array → string)
- World layout completely different (no ground)
- Collision detection updated (1x1 player)
- All positions recalculated (border offsets)

### Backward Compatibility
- Phases 1-5 tests will need updates
- Save/restore positions may break
- Custom player sprites need conversion

### Configuration Updates
```lua
-- Old (Phases 1-5)
setup({
  player_sprite = { " o ", "/|\\" }
})

-- New (Phase 6+)
setup({
  player_sprite = "🚶",  -- or "●" for ASCII
  border = {
    top = 3,
    bottom = 2,
    left = 2,
    right = 2
  }
})
```

## Visual Examples

### Small Directory (Top-Down)
```
╔═══════╗
║  src  ║
║       ║
╚═══════╝
    ↑
 entrance
```

### File Placement
```
╔═════╗
║ lua ║  📜 init.lua
╚═════╝
         📄 README.md
   🚶
(player)
         🐍 script.py
```

### Full Buffer Example
```
┌──────────────────────────────────────┐
│ 📁 /home/user/project                │
│ <CR> to enter lua                    │
├──────────────────────────────────────┤
│                                      │
│   ╔═════╗    📜 main.lua            │
│   ║ src ║                           │
│   ╚═════╝         🚶                │
│                (player)              │
│                                      │
│   📄 README.md    ╔═══════╗         │
│                   ║ tests ║         │
│   🐍 setup.py     ╚═══════╝         │
│                                      │
├──────────────────────────────────────┤
│ hjkl=move | <CR>=interact | q=quit  │
└──────────────────────────────────────┘
```

## Success Metrics

- [ ] All Phase 1-5 core functionality preserved
- [ ] Top-down view renders correctly
- [ ] Single-character player moves smoothly
- [ ] Objects distributed throughout playable area
- [ ] Border collision works
- [ ] Interaction radius standardized to 1 tile
- [ ] No ground/gravity artifacts
- [ ] All tests passing (after updates)

## Timeline Estimate

- Step 1-2 (Borders & Player): 1-2 hours
- Step 3-4 (Art & Sprites): 1-2 hours
- Step 5-6 (Layout & Render): 2-3 hours
- Step 7-8 (Cleanup & Test): 1-2 hours
- **Total**: 5-9 hours

## Notes

This is a complete visual redesign but preserves all core game mechanics:
- Navigation still works
- Collision detection still works
- Interaction system still works
- File/directory opening still works

The change is primarily in **presentation**, not **functionality**.
