# DirQuest.nvim - Design Document

## Overview
DirQuest is a Neovim plugin that transforms file system navigation into an open-world side-scroller game experience. Users explore their directory structure as an ASCII-rendered world where directories become locations and files become interactive objects.

## Core Concept
- **Medium**: Neovim buffer with ASCII art rendering
- **Navigation**: Standard Vim cursor movement (`h`, `j`, `k`, `l`)
- **Player**: ASCII sprite that represents the cursor position
- **World**: Procedurally rendered ASCII art representing directories
- **Interaction**: Enter key to open directories or files
- **Technology**: 100% Lua, zero external dependencies

## Architecture

### 1. Plugin Structure
```
dirquest.nvim/
├── lua/
│   └── dirquest/
│       ├── init.lua           # Plugin entry point and setup
│       ├── game.lua            # Core game loop and state management
│       ├── renderer.lua        # Buffer rendering and display
│       ├── world.lua           # World generation and location management
│       ├── player.lua          # Player sprite and movement
│       ├── filesystem.lua      # File system interaction layer
│       ├── ascii_art.lua       # ASCII art templates and generation
│       └── input.lua           # Keyboard input handling
└── doc/
    └── dirquest.txt            # Vim help documentation
```

### 2. Core Components

#### 2.1 Game State Manager (`game.lua`)
**Purpose**: Central state management and game loop coordination

**State Structure**:
```lua
{
  current_dir = "/path/to/dir",           -- Current directory path
  player = {
    x = 10,                                -- Player X position in buffer
    y = 5,                                 -- Player Y position in buffer
    sprite = { "^", "|", "/" }             -- Player ASCII sprite (multi-line)
  },
  world = {
    locations = {},                        -- Table of directory locations
    objects = {},                          -- Table of file objects
    layout = {}                            -- 2D array of the rendered world
  },
  buffer = nil,                            -- Neovim buffer handle
  window = nil,                            -- Neovim window handle
  mode = "explore"                         -- "explore" or "menu"
}
```

**Functions**:
- `init()` - Initialize game state
- `start(directory)` - Start game in specified directory
- `update()` - Main game loop tick
- `close()` - Clean up and exit

#### 2.2 Renderer (`renderer.lua`)
**Purpose**: Manage buffer content and display

**Functions**:
- `create_buffer()` - Create and configure the game buffer
- `clear()` - Clear buffer contents
- `draw_world(world_data)` - Render world layout to buffer
- `draw_player(player)` - Draw player sprite at position
- `draw_hud(info)` - Draw HUD showing current path, controls
- `highlight_interactive(locations, objects)` - Add highlights to interactive elements
- `get_buffer_dimensions()` - Return usable buffer width/height

**Buffer Configuration**:
- `buftype = 'nofile'`
- `bufhidden = 'wipe'`
- `swapfile = false`
- `modifiable = false` (except during rendering)

#### 2.3 World Generator (`world.lua`)
**Purpose**: Generate ASCII world from directory structure

**Location Object**:
```lua
{
  type = "directory",
  name = "src",
  path = "/home/user/project/src",
  x = 20,                      -- Start X position
  y = 10,                      -- Start Y position
  width = 30,                  -- Width of the location
  height = 15,                 -- Height of the location
  art = {},                    -- ASCII art lines
  entrance = { x = 25, y = 24 }, -- Entrance coordinates (future)
  is_directory = true          -- Directory flag
}
```

**Collision Rectangle**:
```lua
{
  x = 20,                      -- Start X position
  y = 10,                      -- Start Y position
  width = 30,                  -- Width of collision area
  height = 15,                 -- Height of collision area
  type = "structure",          -- "structure" or "ground"
  object = location            -- Reference to location/object (optional)
}
```

**File Object**:
```lua
{
  type = "file",
  name = "main.lua",
  path = "/home/user/project/main.lua",
  x = 45,
  y = 18,
  sprite = {},                 -- Small ASCII sprite
  file_type = "lua"            -- Extension-based type
}
```

**Functions**:
- `generate_world(width, height)` - Create world from directory
- `draw_ground(world)` - Draw ground and add collision rect
- `layout_locations(world)` - Arrange locations spatially
- `draw_location(world, location)` - Draw location art to grid
- `place_files(world)` - Place file sprites
- `draw_object(world, obj)` - Draw object sprite to grid
- `get_object_at(world, x, y)` - Return location/object at coordinates

**Layout Algorithm**:
1. Read directory contents
2. Separate directories and files
3. Generate ASCII art for each directory (location)
4. Position locations left-to-right with spacing
5. Place file objects within/near locations
6. Build 2D character array of the complete world

#### 2.4 Player Controller (`player.lua`)
**Purpose**: Handle player sprite and movement logic

**Sprite Design**:
```lua
-- Default player sprite (3x2)
{
  " o ",
  "/|\\"
}
```

**Functions**:
- `move(direction, world_width, world_height, world)` - Move player in direction
- `can_move_to(x, y, world_width, world_height, world, direction)` - Check collision/boundaries
- `rects_overlap(rect1, rect2)` - Check if two rectangles overlap (AABB collision)
- `get_position()` - Return current player position
- `set_position(x, y)` - Set player position

**Movement Rules**:
- Cannot move through location boundaries (structure collision rectangles)
- Can enter locations through entrances
- Free movement in open space
- Coordinate-based collision detection with structures and ground

#### 2.5 Filesystem Interface (`filesystem.lua`)
**Purpose**: Abstract file system operations

**Functions**:
- `read_directory(path)` - Return table of dirs and files
- `is_directory(path)` - Check if path is directory
- `open_file(path)` - Open file in new buffer/window
- `get_parent_directory(path)` - Return parent path
- `get_file_type(path)` - Return file extension/type

**Implementation**:
- Use Lua's `io.popen("ls")` or `vim.fn.readdir()`
- Use `vim.fn.isdirectory()`
- Use `vim.cmd.edit()` for opening files
- Pure Lua string manipulation for paths

#### 2.6 ASCII Art Generator (`ascii_art.lua`)
**Purpose**: Generate and store ASCII art templates

**Directory Art Templates**:
Multiple templates based on directory size/content:

```lua
-- Small building (for directories with few files)
{
  "    ___  ",
  "   |   | ",
  "   | D |",
  "   |___| ",
  "  /     \\",
  " /       \\",
  "-----------"
}

-- Large castle (for directories with many subdirs)
{
  "     ___       ___     ",
  "    |   |     |   |    ",
  "    |   |_____|   |    ",
  "    |             |    ",
  "    |   DIRNAME   |    ",
  "    |             |    ",
  "    |_____   _____|    ",
  "          | |          ",
  "    ====================",
}

-- Cave entrance (for hidden directories)
{
  "  /\\  /\\  /\\  ",
  " /  \\/  \\/  \\ ",
  "|    .name   |",
  "|            |",
  " \\          / ",
  "  \\________/  "
}
```

**File Sprites by Type**:
```lua
file_sprites = {
  lua = { "📜", "LUA" },      -- Scroll for scripts
  txt = { "📄", "TXT" },      -- Paper
  md = { "📝", "MD" },        -- Note
  png = { "🖼️ ", "IMG" },     -- Picture frame
  default = { "📦", "FILE" }  -- Box
}
```

**Functions**:
- `get_directory_art(name, size, type)` - Return art with name embedded
- `get_file_sprite(filename)` - Return sprite based on extension
- `embed_text(art, text, position)` - Insert text into art
- `generate_ground(width)` - Create ground/floor patterns

#### 2.7 Input Handler (`input.lua`)
**Purpose**: Map keyboard input to game actions

**Key Mappings**:
```lua
{
  h = "move_left",
  j = "move_down",
  k = "move_up",
  l = "move_right",
  ["<CR>"] = "interact",      -- Enter location/open file
  ["<Esc>"] = "go_back",      -- Exit location or quit
  q = "quit",
  r = "refresh",              -- Reload directory
  ["?"] = "help"
}
```

**Functions**:
- `setup_keymaps(buffer)` - Configure buffer-local keymaps
- `handle_movement(direction)` - Process movement input
- `handle_interaction()` - Process Enter key
- `handle_back()` - Go to parent directory

## Game Flow

### 3.1 Initialization
1. User runs `:DirQuest` or `:DirQuest /path/to/dir`
2. Plugin creates new buffer and window
3. Game state initialized with starting directory
4. World generated from directory contents
5. Player spawned at left side of world
6. Initial render performed
7. Keymaps activated

### 3.2 Exploration Mode
1. Player moves using hjkl
2. Renderer updates player position
3. HUD shows current directory path
4. Interactive elements highlighted
5. Collision detection prevents invalid moves
6. When player reaches entrance of location and presses Enter:
   - Load subdirectory
   - Generate new world
   - Reset player position
7. When player reaches file and presses Enter:
   - Exit game buffer
   - Open file in normal buffer

### 3.3 Navigation States

**State 1: Root Directory View**
- Display all directories as locations
- Display files as objects
- Player can move freely between locations
- Enter locations to dive deeper

**State 2: Inside Location View**
- Show contents of selected directory
- Show subdirectories as smaller locations
- Show files as interactive objects
- Press Escape to return to parent

### 3.4 Rendering Pipeline
1. Calculate buffer dimensions
2. Create 2D array of spaces (empty world)
3. Draw ground layer
4. Draw location structures
5. Draw file objects
6. Draw player sprite
7. Draw HUD overlay
8. Convert 2D array to buffer lines
9. Apply syntax highlighting
10. Set buffer as unmodifiable

## Implementation Details

### 4.1 Coordinate System
- Origin (0,0) at top-left of buffer
- X increases rightward
- Y increases downward
- Player position is center of sprite
- World can be larger than viewport (scroll handled by Neovim)

### 4.2 Collision Detection

The collision system uses **coordinate-based rectangle overlap detection** (AABB - Axis-Aligned Bounding Box) instead of checking ASCII symbols in the grid. This provides a clean separation between visual representation and collision logic.

**World Structure**:
```lua
world = {
  width = 150,
  height = 20,
  grid = {},                   -- 2D array for visual display
  collision_rects = {},        -- Array of collision rectangles
  locations = {},              -- Array of location objects
  objects = {},                -- Array of file objects
  ground_level = 15
}
```

**Collision Detection Algorithm**:
```lua
function can_move_to(x, y, world_width, world_height, world, direction)
  -- Check buffer boundaries
  if x < 0 or y < 0 then return false end
  if x >= world_width or y >= world_height then return false end
  
  -- Create player bounding box
  local player_rect = {
    x = x,
    y = y,
    width = sprite_width,
    height = sprite_height
  }
  
  -- Check collision with each rect
  for _, collision_rect in ipairs(world.collision_rects) do
    if collision_rect.type == "ground" then
      -- Ground only blocks downward movement
      if direction == "down" and rects_overlap(player_rect, collision_rect) then
        return false
      end
    elseif collision_rect.type == "structure" then
      -- Structures block all directions
      if rects_overlap(player_rect, collision_rect) then
        return false
      end
    end
  end
  
  return true
end

function rects_overlap(rect1, rect2)
  return rect1.x < rect2.x + rect2.width and
         rect1.x + rect1.width > rect2.x and
         rect1.y < rect2.y + rect2.height and
         rect1.y + rect1.height > rect2.y
end
```

**Collision Registration**:
When world objects are created, collision rectangles are automatically registered:
```lua
-- Ground collision
table.insert(world.collision_rects, {
  x = 1,
  y = world.ground_level,
  width = world.width,
  height = 1,
  type = "ground"
})

-- Structure collision
table.insert(world.collision_rects, {
  x = location.x,
  y = location.y,
  width = location.width,
  height = location.height,
  type = "structure",
  object = location
})
```

**Benefits of Coordinate-Based Collision**:
- Visual grid and collision logic are decoupled
- Player sprite characters don't interfere with collision checks
- More efficient (O(n) collision rects vs O(width × height) grid checks)
- Easy to add new collision types or modify behavior
- Cleaner, more maintainable code

### 4.3 World Layout Algorithm
```lua
function layout_locations(directories, files)
  local x_offset = 5
  local locations = {}
  
  for i, dir in ipairs(directories) do
    local art = get_directory_art(dir.name, #dir.contents)
    local location = {
      name = dir.name,
      x = x_offset,
      y = 5,  -- Ground level
      art = art,
      width = #art[1],
      height = #art
    }
    table.insert(locations, location)
    x_offset = x_offset + location.width + 10  -- Spacing
  end
  
  -- Place files near their parent locations
  -- ...
  
  return locations
end
```

### 4.4 ASCII Art Embedding
```lua
function embed_text(art, text, position)
  -- Find center of art if position is "center"
  -- Truncate text if too long
  -- Insert text into art array
  -- Return modified art
end
```

### 4.5 Directory Size Heuristics
- Small: < 5 items → Small building
- Medium: 5-15 items → Medium structure
- Large: > 15 items → Large castle
- Hidden (starts with .): Cave/underground entrance

## User Interface

### 5.1 HUD Layout
```
┌─────────────────────────────────────────────────────────┐
│ DirQuest | Path: /home/user/project/src | ? for help   │
└─────────────────────────────────────────────────────────┘
```

### 5.2 Visual Elements
- **Ground**: `=========` or `---------` patterns
- **Sky**: Empty space above locations
- **Walls**: `|`, `│`, `/`, `\` for structure edges
- **Entrances**: Gap in structure marked with special char

### 5.3 Highlights
```lua
vim.api.nvim_set_hl(0, "DirQuestPlayer", { fg = "#FFD700", bold = true })
vim.api.nvim_set_hl(0, "DirQuestLocation", { fg = "#87CEEB" })
vim.api.nvim_set_hl(0, "DirQuestFile", { fg = "#90EE90" })
vim.api.nvim_set_hl(0, "DirQuestGround", { fg = "#8B4513" })
```

## API & Configuration

### 6.1 User Commands
```lua
:DirQuest [path]      -- Start game in path (default: current dir)
:DirQuestQuit         -- Exit game
:DirQuestRefresh      -- Reload current directory
```

### 6.2 Lua API
```lua
require('dirquest').setup({
  player_sprite = { " o ", "/|\\" },
  auto_center = true,          -- Keep player centered
  show_hidden = false,         -- Show hidden files
  file_icons = true,           -- Use ASCII file icons
  custom_templates = {}        -- User-defined location art
})

require('dirquest').start(path)
require('dirquest').close()
```

### 6.3 Configuration Options
```lua
{
  player_sprite = { " o ", "/|\\" },
  movement_speed = 1,           -- Cells per keypress
  show_hidden_files = false,
  auto_center_player = false,
  location_spacing = 10,        -- Spaces between locations
  max_world_width = 500,        -- Maximum world width
  ground_level = 20,            -- Y position of ground
  art_style = "ascii",          -- "ascii" or "unicode"
}
```

## Technical Considerations

### 7.1 Performance
- Cache directory listings to avoid repeated filesystem calls
- Limit world width to prevent massive buffers
- Only render visible viewport (future optimization)
- Lazy-load subdirectories until entered

### 7.2 Edge Cases
- Empty directories: Show empty building with "EMPTY" text
- Permission denied: Show locked location with padlock
- Symlinks: Show as portal with link indicator
- Very long filenames: Truncate in display
- Binary files: Distinguish from text files

### 7.3 Error Handling
- Graceful failure if directory unreadable
- Message display for errors
- Fallback to parent directory if current becomes invalid

## Future Enhancements (v2.0+)

### Phase 2 Features
- Multiple player sprites (unlockable)
- Animated sprites (frame-by-frame)
- Sound effects via terminal bell patterns
- Particle effects for interactions
- Mini-map in corner

### Phase 3 Features
- Multiplayer in shared directories
- File operations (move, copy, delete) as game actions
- Quest system for file organization tasks
- Achievement system

### Phase 4 Features
- Custom world themes
- Seasonal events
- Plugin ecosystem for custom locations

## Development Phases

### Phase 1: Core MVP
1. Basic buffer management and rendering
2. Simple player movement
3. Basic directory/file display
4. Enter/exit directories
5. Open files

### Phase 2: Polish
1. ASCII art for locations
2. File type sprites
3. Collision detection
4. HUD and help system
5. Configuration options

### Phase 3: Enhancement
1. Better world layout
2. Smooth scrolling
3. Performance optimization
4. Custom art templates
5. Comprehensive documentation

## Testing Strategy

### Manual Testing Checklist
- [ ] Navigate through nested directories
- [ ] Open various file types
- [ ] Test with empty directories
- [ ] Test with large directories (100+ files)
- [ ] Test with long filenames
- [ ] Test with hidden files
- [ ] Test edge cases (symlinks, permissions)
- [ ] Test all keybindings
- [ ] Test quit and cleanup

### Test Directories
Create test directory structures:
- Simple (few files and dirs)
- Complex (deep nesting)
- Large (many files)
- Special (hidden, symlinks, permissions)

## Documentation Requirements

### User Documentation
- README with gameplay instructions
- Vim help file (`:help dirquest`)
- GIF/screenshot demos
- Configuration examples

### Developer Documentation
- Code comments for complex logic
- Architecture diagram
- Extension/customization guide
- Contributing guidelines

---

## Quick Start Implementation Order

1. **Session 1**: `init.lua`, basic buffer creation, simple rendering
2. **Session 2**: `filesystem.lua`, directory reading, basic world data
3. **Session 3**: `player.lua`, movement, input handling
4. **Session 4**: `world.lua`, location generation, layout
5. **Session 5**: `ascii_art.lua`, templates and embedding
6. **Session 6**: `renderer.lua`, complete rendering pipeline
7. **Session 7**: Integration, testing, polish
8. **Session 8**: Configuration, documentation, packaging

---

**End of Design Document**

This design provides a complete blueprint for implementing DirQuest.nvim as a playable, functional file explorer game entirely in Lua with no external dependencies.
