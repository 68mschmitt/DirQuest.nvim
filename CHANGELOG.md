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

## [Unreleased]

### Phase 2 - Coming Next
- File system reading functionality
- Directory content listing
- File and directory distinction
- Basic navigation between directories

### Future Phases
- Player sprite and movement (Phase 3)
- World generation with ASCII art (Phase 4)
- Collision detection and interaction (Phase 5)
- Visual polish and enhanced art (Phase 6)
- Configuration and customization (Phase 7)
- Error handling and edge cases (Phase 8)
- Performance optimization (Phase 9)
- Documentation and final polish (Phase 10)
