# 🎮 DirQuest.nvim

Transform your file system navigation into an open-world side-scroller adventure! DirQuest is a Neovim plugin that reimagines the traditional file explorer as an ASCII-rendered game world where directories become locations and files become interactive objects.

## ✨ Features

- **Game-like Navigation**: Use standard Vim movements (hjkl) to control your player character
- **ASCII Art World**: Directories rendered as beautiful ASCII structures
- **Interactive Exploration**: Press Enter to dive into directories or open files
- **Pure Lua**: 100% Lua implementation with zero external dependencies
- **Lightweight**: Fast and efficient, designed for Neovim

## 🚀 Current Status: Phase 4+ (v0.4.0)

DirQuest is under active development. Currently implemented:

### Core Infrastructure
- ✅ Buffer and plugin infrastructure
- ✅ Buffer creation and management
- ✅ Quit functionality
- ✅ File system reading and directory listing

### Navigation & Interaction
- ✅ Navigate into subdirectories
- ✅ Distinguish between files and directories
- ✅ Open files from the explorer
- ✅ Navigate to parent directory

### Player & Movement
- ✅ Player sprite rendering (customizable)
- ✅ HJKL movement controls
- ✅ 2D world view with player
- ✅ Boundary checking

### World Generation
- ✅ ASCII art world generation
- ✅ Directory structures as ASCII art boxes (3 sizes)
- ✅ Size-based template selection
- ✅ Ground/floor rendering
- ✅ File sprites with type indicators
- ✅ Horizontal world layout with spacing
- ✅ Scrollable worlds (wider than screen)

### Collision System
- ✅ **Coordinate-based collision detection**
- ✅ **AABB (rectangle overlap) collision**
- ✅ **Structure collision** (can't walk through directories)
- ✅ **Ground collision** (can't fall through floor)
- ✅ **Optimized collision checking** (O(n) performance)

Coming soon:
- 🎯 Entrance/door system for directories
- 🎯 Interaction prompts
- 🎨 Visual polish and customization
- 🏰 Enhanced ASCII art variety

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  '68mschmitt/dirquest.nvim',
  config = function()
    require('dirquest').setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wabbittwacks/packer.nvim)

```lua
use {
  '68mschmitt/dirquest.nvim',
  config = function()
    require('dirquest').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug '68mschmitt/dirquest.nvim'

lua << EOF
require('dirquest').setup()
EOF
```

## 🎮 Usage

### Commands

- `:DirQuest [path]` - Start the game (opens in specified directory or current directory)
- `:DirQuestQuit` - Exit the game

### Keybindings (In-game)

Currently available:
- `h`, `j`, `k`, `l` - Move player character in 2D world
- `q` / `<Esc>` - Quit DirQuest
- `<CR>` (Enter) - Open directory or file
- `-` - Go to parent directory

Coming in future phases:
- `r` - Refresh current directory
- `?` - Show help
- More interactive elements

## ⚙️ Configuration

```lua
require('dirquest').setup({
  -- Available now (Phase 4):
  player_sprite = { " o ", "/|\\" },  -- Customize your player sprite
  
  -- Coming in Phase 7:
  -- show_hidden_files = false,
  -- location_spacing = 10,
  -- ground_level = 20,
})
```

### Example: Custom Player Sprite

```lua
require('dirquest').setup({
  player_sprite = {
    " @ ",    -- Head row
    "/|\\"    -- Body row
  }
})
```

## 🎯 Roadmap

### Phase 1: Basic Buffer and Plugin Infrastructure ✅
- Plugin entry point and command registration
- Buffer creation and configuration
- Basic window management
- Clean shutdown

### Phase 2: File System Reading ✅
- Directory reading from file system
- Distinguishing between files and directories
- Display current directory path
- List all items in current directory
- Navigate into subdirectories
- Open files

### Phase 3: Player Sprite and Movement ✅
- Player sprite rendering
- HJKL movement controls
- Player position tracking
- Basic boundary checking
- 2D world view

### Phase 4: Simple World Generation ✅
- 2D coordinate system for world layout
- Simple ASCII art for directories (3 size templates)
- Ground/floor rendering
- Directory structures positioned horizontally
- File sprites with type indicators
- **Coordinate-based collision system** ⭐
- **AABB rectangle overlap detection** ⭐
- **Structure and ground collision** ⭐

### Phase 5: Collision Detection and Interaction (Partial)
- ✅ Collision detection with directory structures
- ✅ Prevent walking through walls
- ⏳ Entrance/door system for directories
- ⏳ Interaction prompts
- ✅ Basic file/directory interaction

### Phase 6: Enhanced ASCII Art and Visual Polish
- Multiple directory art templates
- File type-specific sprites
- Syntax highlighting
- HUD with path and controls

### Phase 7: Configuration and Customization
- User configuration options
- Custom player sprites
- Custom keybindings
- Color customization

### Phase 8: Error Handling and Edge Cases
- Permission handling
- Symlink support
- Long filename handling
- Graceful error recovery

### Phase 9: Performance and Optimization
- Directory caching
- Large directory handling
- Render optimization
- Memory management

### Phase 10: Documentation and Polish
- In-game help system
- Comprehensive documentation
- Examples and demos
- Release preparation

## 🎨 Vision

DirQuest transforms the mundane task of file navigation into an adventure:

- **Directories as Locations**: ✅ Small directories appear as small boxes, medium as buildings, large as structures
- **Files as Objects**: ✅ Different file types represented by unique sprites ([L] for Lua, [T] for text, etc.)
- **Exploration**: ✅ Navigate your file system spatially through a 2D ASCII landscape
- **Collision System**: ✅ Can't walk through structures or fall through the ground
- **Interaction**: ✅ Walk into directories and press Enter to explore, or interact with files to open them

**What's Working Now**:
```
📁 /your/project/directory

     ___        _____       _______    
    |   |      |     |     |       |   
    | A |      |  B  |     |   C   |   [L] [T] [M]
    |___|      |_____|     |_______|   
  ========================================
      o
     /|\    <-- You can move around!
```

## 🤝 Contributing

DirQuest is in active development! Contributions, ideas, and feedback are welcome.

1. Check the [DESIGN.md](docs/DESIGN.md) for architecture details
2. Review [SPEC.md](docs/SPEC.md) for development phases and testing procedures
3. Open an issue or PR

## 📚 Documentation

- [Design Document](docs/DESIGN.md) - Complete architectural overview (updated with collision system)
- [Development Spec](docs/SPEC.md) - Phase-by-phase implementation guide
- [Quick Start Guide](docs/QUICKSTART.md) - Testing and getting started
- [Phase 1 Complete](docs/PHASE1_COMPLETE.md) - Phase 1 implementation summary
- [Phase 2 Complete](docs/PHASE2_COMPLETE.md) - Phase 2 implementation summary
- [Phase 3 Complete](docs/PHASE3_COMPLETE.md) - Phase 3 implementation summary
- [Phase 4 Complete](docs/PHASE4_COMPLETE.md) - Phase 4 implementation summary (includes collision system)
- Vim help (coming in Phase 10): `:help dirquest`

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

Inspired by the creative spirit of games like Townscaper and the productivity of Vim file explorers like NERDTree and nvim-tree.

---

**Note**: DirQuest is currently in Phase 4+ of development. The core gameplay loop is functional with ASCII art world generation, player movement, and collision detection. Star and watch this repository to follow along as we build out enhanced features!

## 🐛 Known Issues

- Player starting position may overlap with first directory structure (use movement keys to navigate away)
- No entrance/door system yet - directories can be entered from anywhere by pressing Enter while near them
- File sprites don't have collision (you can walk over them)

## 💡 Future Ideas (v2.0+)

- Animated sprites
- Multiple player characters
- File operations (move, copy, delete) as game actions
- Quest system for file organization
- Multiplayer in shared directories
- Custom themes and seasons
- Achievement system

---

Made with ❤️ for the Neovim community
