# DirQuest.nvim - Design Document

## Overview
DirQuest is a Neovim plugin that transforms file system navigation into an open-world top-down exploration game. Users explore their directory structure as an ASCII-rendered world where directories become locations and files become interactive objects.

## Core Concept
- **Medium**: Neovim buffer with ASCII art rendering
- **View**: Top-down perspective (bird's-eye view)
- **Navigation**: Standard Vim cursor movement (`h`, `j`, `k`, `l`)
- **Player**: Single character emoji sprite (🚶 by default, cursor as fallback)
- **World**: Procedurally rendered ASCII art filling the entire buffer space
- **Border**: Buffer defines internal border as navigable play area
- **Interaction**: Enter key to open directories or files
- **Technology**: 100% Lua, zero external dependencies

## Visual Paradigm Shift

**Previous Design (Phases 1-5)**: Side-scroller with ground
**New Design (Phase 6+)**: Top-down exploration

```
Before (Side View):              After (Top View):
                                 ┌─────────────────┐
     ___    _____                │ ╔═════════════╗ │
    |   |  |     |               │ ║   📁 src    ║ │
    | A |  |  B  |    [F]        │ ║             ║ │
    |___|  |_____|               │ ╚═════════════╝ │
  ==================             │                 │
      ^                          │      🚶         │
    player                       │   (player)      │
                                 │                 │
                                 │  📄 main.lua    │
                                 └─────────────────┘
```

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
    sprite = "🚶"                          -- Player single-char sprite (emoji)
  },
  world = {
    border = { left = 2, right = 2,        -- Buffer border dimensions
               top = 3, bottom = 2 },
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

**Buffer Layout**:
```
┌────────────────────────────────┐ ← Top border (line 1-3)
│  📁 /current/directory         │ ← HUD area
│  Controls: hjkl=move, <CR>=...│
├────────────────────────────────┤ ← Border line
│                                │
│    ╔═══════╗      📄 file.lua │
│    ║  src  ║                  │ ← Playable area
│    ╚═══════╝      🚶          │   (fills entire buffer)
│                                │
├────────────────────────────────┤ ← Bottom border
│  Status info                   │
└────────────────────────────────┘
```

#### 2.3 World Generator (`world.lua`)
**Purpose**: Generate ASCII world from directory structure

**Location Object (Top-Down)**:
```lua
{
  type = "directory",
  name = "src",
  path = "/home/user/project/src",
  x = 20,                      -- Center X position in playable area
  y = 10,                      -- Center Y position in playable area
  width = 10,                  -- Width of directory box
  height = 5,                  -- Height of directory box
  art = {},                    -- ASCII art lines (box with name)
  entrance = { x = 20, y = 14 }, -- Entrance at bottom center
  interaction_radius = 1,      -- Player can interact within 1 tile
  is_directory = true          -- Directory flag
}
```

**File Object (Top-Down)**:
```lua
{
  type = "file",
  name = "main.lua",
  path = "/home/user/project/main.lua",
  x = 45,                      -- Center X position
  y = 18,                      -- Center Y position
  sprite = "📄",               -- Single character (emoji or ASCII)
  interaction_radius = 1,      -- Player can interact within 1 tile
  file_type = "lua"            -- Extension-based type
}
```

**Collision Rectangle**:
```lua
{
  x = 20,                      -- Start X position
  y = 10,                      -- Start Y position
  width = 10,                  -- Width of collision area
  height = 5,                  -- Height of collision area
  type = "structure",          -- "structure", "border", or "file"
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

**Sprite Design (New - Phase 6+)**:
```lua
-- Default player sprite (single character)
sprite = "🚶"  -- Walking person emoji

-- Animation frames (future):
animations = {
  idle = "🧍",
  walk_up = "🚶",
  walk_down = "🚶",
  walk_left = "🚶",
  walk_right = "🚶"
}

-- Fallback for non-emoji terminals:
sprite = "●"  -- or cursor position
```

**Functions**:
- `move(direction, world_width, world_height, world)` - Move player in direction
- `can_move_to(x, y, world_width, world_height, world, direction)` - Check collision/boundaries
- `rects_overlap(rect1, rect2)` - Check if two rectangles overlap (AABB collision)
- `get_position()` - Return current player position
- `set_position(x, y)` - Set player position

**Movement Rules (Top-Down)**:
- Cannot move through directory structure boundaries
- Cannot move outside buffer border area
- Can move freely in playable area
- Entrance interaction: player within 1 tile of entrance point
- File interaction: player within 1 tile of file sprite
- Coordinate-based collision detection with all objects

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

**Directory Art Templates (Top-Down View)**:
Box-style templates for top-down perspective:

```lua
-- Small directory (< 5 items)
{
  "╔═══════╗",
  "║ name  ║",
  "║       ║",
  "╚═══════╝"
}

-- Medium directory (5-15 items)
{
  "╔═══════════╗",
  "║   name    ║",
  "║           ║",
  "║           ║",
  "╚═══════════╝"
}

-- Large directory (> 15 items)
{
  "╔═══════════════╗",
  "║     name      ║",
  "║               ║",
  "║               ║",
  "║               ║",
  "╚═══════════════╝"
}

-- Hidden directory (starts with .)
{
  "┌─────────┐",
  "│  .name  │",
  "│  (hide) │",
  "└─────────┘"
}
```

**Entrance Standardization**:
- All directory entrances at bottom-center of box
- Interaction radius: 1 tile (standardized)
- Visual indicator: gap or special character at entrance

**File Sprites (Top-Down - Single Character)**:
```lua
file_sprites = {
  lua = "📜",       -- Lua script
  txt = "📄",       -- Text file
  md = "📝",        -- Markdown
  js = "📘",        -- JavaScript
  py = "🐍",        -- Python
  png = "🖼️",       -- Image
  default = "📦"   -- Generic file
}

-- Interaction zone: 1 tile radius around sprite
interaction_radius = 1
```

**Functions**:
- `get_directory_art(name, size, type)` - Return top-down box art with name
- `get_file_sprite(filename)` - Return single-char emoji sprite
- `embed_text(art, text, position)` - Insert text into art
- `generate_border(width, height)` - Create buffer border lines

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

### 3.1 Initialization (Top-Down)
1. User runs `:DirQuest` or `:DirQuest /path/to/dir`
2. Plugin creates new buffer and window
3. Calculate playable area (buffer dimensions minus borders)
4. Game state initialized with starting directory
5. World generated from directory contents (fills entire playable area)
6. Player spawned at center or safe spawn point
7. Initial render performed with borders
8. Keymaps activated

### 3.2 Exploration Mode (Top-Down)
1. Player moves using hjkl (single character, moves 1 tile at a time)
2. Renderer updates player position (emoji sprite)
3. HUD shows current directory path at top
4. Interactive elements use emoji sprites
5. Collision detection:
   - Prevents moving through directory boxes
   - Prevents moving outside buffer border
   - No "ground" collision (top-down view)
6. When player within 1 tile of entrance and presses Enter:
   - Load subdirectory
   - Generate new world (fills buffer)
   - Spawn player at safe location
7. When player within 1 tile of file and presses Enter:
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

### 3.4 Rendering Pipeline (Top-Down)
1. Calculate buffer dimensions
2. Calculate playable area (minus borders)
3. Create 2D array of spaces (empty world)
4. Draw buffer borders (top, bottom, left, right)
5. Draw HUD in top border area
6. Distribute directory boxes throughout playable area
7. Place file sprites in open spaces
8. Draw player sprite (single emoji character)
9. Draw status line in bottom border
10. Convert 2D array to buffer lines
11. Apply syntax highlighting
12. Set buffer as unmodifiable

## Implementation Details

### 4.1 Coordinate System (Top-Down)
- Origin (0,0) at top-left of buffer
- X increases rightward
- Y increases downward
- Border offsets:
  - `border.top` lines reserved for HUD (default: 3)
  - `border.bottom` lines reserved for status (default: 2)
  - `border.left` columns reserved (default: 2)
  - `border.right` columns reserved (default: 2)
- Playable area: `(border.left, border.top)` to `(width - border.right, height - border.bottom)`
- Player position is single cell (1x1)
- World fills entire playable area (no scrolling needed)

### 4.2 Collision Detection

The collision system uses **coordinate-based rectangle overlap detection** (AABB - Axis-Aligned Bounding Box) instead of checking ASCII symbols in the grid. This provides a clean separation between visual representation and collision logic.

**World Structure (Top-Down)**:
```lua
world = {
  width = 80,                  -- Total buffer width
  height = 24,                 -- Total buffer height
  border = {                   -- Border dimensions
    top = 3,
    bottom = 2,
    left = 2,
    right = 2
  },
  playable_area = {            -- Calculated playable space
    x_start = 2,
    y_start = 3,
    x_end = 78,
    y_end = 22,
    width = 76,
    height = 19
  },
  grid = {},                   -- 2D array for visual display
  collision_rects = {},        -- Array of collision rectangles (includes borders)
  locations = {},              -- Array of location objects
  objects = {}                 -- Array of file objects
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
