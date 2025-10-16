# Changelog

All notable changes to DirQuest.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-16

### Added
- Initial Phase 1 implementation
- Basic plugin infrastructure and entry point
- Buffer creation and configuration
- Simple welcome screen rendering
- Quit functionality with `q` and `<Esc>` keybindings
- `:DirQuest` command to start the game
- `:DirQuestQuit` command to exit the game
- Buffer set to `nofile`, `nomodifiable`, and `wipe` on hide
- State management for buffer and window
- `setup()` function for future configuration
- Comprehensive documentation (README, DESIGN, SPEC, QUICKSTART)
- MIT License

### Technical Details
- `lua/dirquest/init.lua` - Main plugin entry point and state management
- `lua/dirquest/renderer.lua` - Buffer creation and rendering
- `plugin/dirquest.vim` - Vim command registration
- Pure Lua implementation with no external dependencies

### Known Limitations
- Only basic buffer display implemented
- No file system interaction yet
- No player movement yet
- No world generation yet

## [0.2.0] - 2025-10-16

### Added
- Phase 2 implementation - File System Reading
- `filesystem.lua` module with directory reading functions
- `game.lua` module with state management
- Directory content listing (files and directories)
- Distinguish between files and directories with [DIR] and [FILE] prefixes
- Navigate into subdirectories with Enter key
- Navigate to parent directory with `-` key
- Display current directory path in header
- Support for `:DirQuest [path]` to start in specific directory
- Empty directory detection and display
- Error handling for unreadable directories

### Changed
- Updated `init.lua` to use game state management
- Updated `renderer.lua` to display directory contents
- Version bumped to 0.2.0
- Updated plugin command to accept optional path argument

### Technical Details
- `lua/dirquest/filesystem.lua` - File system operations
- `lua/dirquest/game.lua` - Game state and navigation logic
- Proper separation of concerns between modules
- Directory items sorted alphabetically (case-insensitive)

## [Unreleased]

### Phase 3 - Coming Next
- Player sprite rendering
- HJKL movement controls
- Player position tracking
- Basic boundary checking

### Future Phases
- Player sprite and movement (Phase 3)
- World generation with ASCII art (Phase 4)
- Collision detection and interaction (Phase 5)
- Visual polish and enhanced art (Phase 6)
- Configuration and customization (Phase 7)
- Error handling and edge cases (Phase 8)
- Performance optimization (Phase 9)
- Documentation and final polish (Phase 10)
