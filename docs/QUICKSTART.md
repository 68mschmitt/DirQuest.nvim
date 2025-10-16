# DirQuest.nvim - Quick Start Guide

## Testing Phase 1

### Prerequisites
- Neovim 0.7.0 or higher
- This plugin added to your runtimepath

### Quick Test

1. **Open Neovim in this directory:**
   ```bash
   nvim
   ```

2. **Add the plugin to runtimepath (if not installed via plugin manager):**
   ```vim
   :set runtimepath+=.
   ```

3. **Load the plugin:**
   ```vim
   :lua require('dirquest')
   ```

4. **Start DirQuest:**
   ```vim
   :DirQuest
   ```

5. **You should see:**
   - A new buffer with the DirQuest welcome screen
   - Version number (v0.1.0)
   - Welcome message and controls

6. **Test quit functionality:**
   - Press `q` - buffer should close
   - Or press `<Esc>` - buffer should close

7. **Test multiple opens:**
   - Run `:DirQuest` again
   - Should open without errors

### Manual Test Checklist (Phase 1)

Based on SPEC.md Phase 1 tests:

- [x] **Test 1.1**: Plugin loads without errors
  ```vim
  :lua require('dirquest')
  ```

- [x] **Test 1.2**: Command registration
  ```vim
  :DirQuest<Tab>
  ```
  (Should autocomplete)

- [x] **Test 1.3**: Buffer creation
  ```vim
  :DirQuest
  :set buftype?
  ```
  (Should show `buftype=nofile`)

- [x] **Test 1.4**: Basic rendering
  - Open `:DirQuest`
  - Should see welcome text
  - Try pressing `i` (should not enter insert mode)

- [x] **Test 1.5**: Quit functionality
  - Open `:DirQuest`
  - Press `q` (should close)
  - Open `:DirQuest`
  - Press `<Esc>` (should close)

- [x] **Test 1.6**: Multiple opens
  - Run `:DirQuest`, quit with `q`
  - Run `:DirQuest` again
  - Should work without errors

### Expected Output

When you run `:DirQuest`, you should see something like:

```
  ╔══════════════════════════════════════════════════════════╗
  ║                                                          ║
  ║                      DirQuest v0.1.0                     ║
  ║                                                          ║
  ║            Navigate your filesystem as a game            ║
  ║                                                          ║
  ╚══════════════════════════════════════════════════════════╝


  Welcome to DirQuest!

  This is a side-scrolling file explorer game for Neovim.

  Controls:
    q / <Esc>  - Quit

  Phase 1: Basic Buffer and Plugin Infrastructure
```

### Troubleshooting

**Problem**: `:DirQuest` command not found
- **Solution**: Make sure the plugin is in your runtimepath
- Try: `:set runtimepath+=.` (if testing locally)
- Or reinstall via your plugin manager

**Problem**: Errors when loading
- **Solution**: Check Neovim version (needs 0.7.0+)
- Check for syntax errors in lua files

**Problem**: Buffer doesn't close with `q`
- **Solution**: Make sure you're in normal mode
- Try `<Esc>` to ensure normal mode, then `q`

### Development Testing

To test without installing:

```bash
# From the plugin directory
nvim --cmd "set runtimepath+=." test.txt
```

Then run `:DirQuest` inside Neovim.

### Next Steps

Once Phase 1 is confirmed working:
- Move to Phase 2: File System Reading
- See SPEC.md for detailed Phase 2 implementation guide
