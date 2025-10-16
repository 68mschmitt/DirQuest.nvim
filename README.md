# 🎮 DirQuest.nvim

Transform your file system navigation into an open-world side-scroller adventure! DirQuest is a Neovim plugin that reimagines the traditional file explorer as an ASCII-rendered game world where directories become locations and files become interactive objects.

## ✨ Features

- **Game-like Navigation**: Use standard Vim movements (hjkl) to control your player character
- **ASCII Art World**: Directories rendered as beautiful ASCII structures
- **Interactive Exploration**: Press Enter to dive into directories or open files
- **Pure Lua**: 100% Lua implementation with zero external dependencies
- **Lightweight**: Fast and efficient, designed for Neovim

## 🚀 Current Status: Phase 1 (v0.1.0)

DirQuest is under active development. Currently implemented:
- ✅ Basic buffer and plugin infrastructure
- ✅ Buffer creation and management
- ✅ Quit functionality

Coming soon:
- 📁 File system reading and directory listing
- 🎮 Player sprite and movement
- 🏰 ASCII art world generation
- 🎯 Collision detection and interaction
- 🎨 Visual polish and customization

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

- `:DirQuest` - Start the game (opens in current directory)
- `:DirQuestQuit` - Exit the game

### Keybindings (In-game)

Currently available:
- `q` - Quit DirQuest
- `<Esc>` - Quit DirQuest

Coming in future phases:
- `h`, `j`, `k`, `l` - Move player character
- `<CR>` (Enter) - Interact with directories/files
- `r` - Refresh current directory
- `?` - Show help

## ⚙️ Configuration

```lua
require('dirquest').setup({
  -- Configuration options coming in Phase 7
  -- player_sprite = { " o ", "/|\\" },
  -- show_hidden_files = false,
  -- location_spacing = 10,
  -- ground_level = 20,
})
```

## 🎯 Roadmap

### Phase 1: Basic Buffer and Plugin Infrastructure ✅
- Plugin entry point and command registration
- Buffer creation and configuration
- Basic window management
- Clean shutdown

### Phase 2: File System Reading (Coming Next)
- Directory reading from file system
- Distinguishing between files and directories
- Display current directory path
- List all items in current directory

### Phase 3: Player Sprite and Movement
- Player sprite rendering
- HJKL movement controls
- Player position tracking
- Basic boundary checking

### Phase 4: Simple World Generation
- 2D coordinate system for world layout
- Simple ASCII art for directories
- Ground/floor rendering
- Scrollable world

### Phase 5: Collision Detection and Interaction
- Collision detection with directory structures
- Entrance/door system for directories
- File interaction system
- Directory navigation

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

DirQuest transforms the mundane task of file navigation into an adventure. Imagine:

- **Directories as Locations**: Small directories appear as cottages, large ones as castles, hidden directories as mysterious caves
- **Files as Objects**: Different file types represented by unique sprites (scrolls for scripts, documents for text files, frames for images)
- **Exploration**: Navigate your file system spatially, discovering directories and files as you move through an ASCII landscape
- **Interaction**: Walk up to a directory entrance and press Enter to dive deeper, or interact with a file to open it

## 🤝 Contributing

DirQuest is in active development! Contributions, ideas, and feedback are welcome.

1. Check the [DESIGN.md](docs/DESIGN.md) for architecture details
2. Review [SPEC.md](docs/SPEC.md) for development phases and testing procedures
3. Open an issue or PR

## 📚 Documentation

- [Design Document](docs/DESIGN.md) - Complete architectural overview
- [Development Spec](docs/SPEC.md) - Phase-by-phase implementation guide
- [Quick Start Guide](docs/QUICKSTART.md) - Testing and getting started
- [Phase 1 Complete](docs/PHASE1_COMPLETE.md) - Phase 1 implementation summary
- Vim help (coming in Phase 10): `:help dirquest`

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

Inspired by the creative spirit of games like Townscaper and the productivity of Vim file explorers like NERDTree and nvim-tree.

---

**Note**: DirQuest is currently in Phase 1 of development. The plugin is functional but minimal. Star and watch this repository to follow along as we build out the full game experience!

## 🐛 Known Issues

None yet! This is Phase 1 - basic functionality only.

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
