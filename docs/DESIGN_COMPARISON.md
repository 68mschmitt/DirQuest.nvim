# DirQuest.nvim - Design Comparison

## Before & After: Visual Paradigm Shift

### BEFORE: Side-Scroller (Phases 1-5)

```
📁 /home/user/project

  ___        _____       _______    
 |   |      |     |     |       |   
 |.git|     | docs|     |  lua  |   [L] main.lua  [T] README  [M] NOTES
 |___|      |_____|     |_______|   
===============================================
    o                                   
   /|\  <-- Player (3×2 multi-line sprite)
```

**Characteristics:**
- Horizontal layout (left to right)
- Ground line at bottom
- Multi-line ASCII art structures
- Player is 3 characters wide, 2 lines tall
- Gravity concept (can't fall through ground)
- Objects clustered near ground level
- Side-scrolling when world wider than screen

---

### AFTER: Top-Down (Phase 6+)

```
┌────────────────────────────────────────────────┐
│ 📁 /home/user/project                          │
│ <CR> to enter lua | hjkl=move | q=quit        │
├────────────────────────────────────────────────┤
│                                                │
│    ╔═══════╗                                  │
│    ║ .git  ║         📜 main.lua              │
│    ╚═══════╝                                  │
│                                                │
│                        🚶  <-- Player (1 char) │
│                                                │
│         ╔═══════╗                             │
│         ║  docs ║      📄 README.md           │
│         ╚═══════╝                             │
│                                                │
│    📝 NOTES.md           ╔═════════╗          │
│                          ║   lua   ║          │
│                          ╚═════════╝          │
│                                                │
├────────────────────────────────────────────────┤
│ Status: Exploring | Files: 3 | Dirs: 3        │
└────────────────────────────────────────────────┘
```

**Characteristics:**
- Bird's-eye view (top-down)
- Buffer border system (HUD + playable area + status)
- Objects distributed throughout entire space
- Player is single emoji character (1×1)
- No gravity concept (free movement)
- Box-drawing style directories (╔═╗)
- Single-character emoji file sprites
- Standardized 1-tile interaction radius
- No scrolling needed (fits in buffer)

---

## Key Differences

| Aspect | Side-Scroller (Before) | Top-Down (After) |
|--------|----------------------|------------------|
| **Perspective** | Profile/side view | Bird's-eye view |
| **Player Sprite** | 3×2 multi-line (`" o "` + `"/|\\"`) | 1×1 single char (`🚶`) |
| **World Layout** | Horizontal (left-right) | Full 2D grid (all directions) |
| **Ground** | Required (bottom line) | None (no gravity) |
| **Borders** | None | HUD top, status bottom |
| **Directory Style** | ASCII buildings | Box-drawing (╔═╗) |
| **File Sprites** | Multi-char labels `[L]` | Single emoji `📜` |
| **Interaction** | 2-tile proximity | 1-tile radius |
| **Space Usage** | Bottom 1/3 of buffer | Entire playable area |
| **Movement** | hjkl (with gravity) | hjkl (free) |

---

## Player Sprite Evolution

### Phase 1-5 (Multi-line)
```
 o     <-- Head
/|\    <-- Body and arms
```
- Width: 3 characters
- Height: 2 lines
- Collision box: 3×2
- Requires careful positioning

### Phase 6+ (Single character)
```
🚶     <-- Entire player
```
- Width: 1 character
- Height: 1 line
- Collision box: 1×1
- Simpler collision detection
- Animation potential: 🧍 (idle), 🚶 (walk)

---

## Directory Representation Evolution

### Phase 1-5 (Side-view buildings)
```
Small:           Medium:          Large:
  ___             _____            _______
 |   |           |     |          |       |
 | A |           |  B  |          |   C   |
 |___|           |     |          |       |
                 |_____|          |       |
                                  |_______|
```

### Phase 6+ (Top-down boxes)
```
Small:           Medium:              Large:
╔═══════╗        ╔═══════════╗        ╔═══════════════╗
║ name  ║        ║   name    ║        ║     name      ║
║       ║        ║           ║        ║               ║
╚═══════╝        ║           ║        ║               ║
                 ╚═══════════╝        ║               ║
                                      ╚═══════════════╝
```

---

## File Representation Evolution

### Phase 1-5 (Multi-character labels)
```
[L]  [T]  [M]  [J]  [P]
lua  txt   md   js   py
```

### Phase 6+ (Single emoji icons)
```
📜   📄   📝   📘   🐍
lua  txt   md   js   py
```

---

## Border System (NEW in Phase 6)

```
┌──────────────────────────────┐  ← Top border start
│ 📁 Directory path            │  ← HUD line 1
│ Controls & interaction hints │  ← HUD line 2
├──────────────────────────────┤  ← Playable area start
│                              │
│   [Playable area with]       │  ← Player moves here
│   [directories and files]    │
│                              │
├──────────────────────────────┤  ← Playable area end
│ Status information           │  ← Status line 1
└──────────────────────────────┘  ← Bottom border end
```

**Border Collision:**
- Player CANNOT move into border areas
- Collision rectangles prevent border entry
- Playable area clearly defined

---

## Interaction System Comparison

### Before (Phase 5)
```
Player near entrance:
     ___
    |   |
    | A |  <- 2 tiles away
    |___|
      ↑ entrance
    
      o    <- Player
     /|\
```
- Detection: 2-tile Manhattan distance
- Entrance: Defined per template
- Interaction: "Press <CR> to enter A"

### After (Phase 6)
```
Player near entrance:
╔═══════╗
║   A   ║
╚═══════╝
    ↑ entrance (bottom center)
    
    🚶  <- Player (1 tile away)
```
- Detection: 1-tile radius (standardized)
- Entrance: Always bottom-center
- Interaction: "Press <CR> to enter A"

---

## Code Impact Summary

### Files Requiring Major Changes
1. `lua/dirquest/player.lua` - Single char sprite
2. `lua/dirquest/ascii_art.lua` - Top-down templates
3. `lua/dirquest/world.lua` - Full-buffer layout
4. `lua/dirquest/renderer.lua` - Border rendering

### Files Requiring Minor Changes
5. `lua/dirquest/init.lua` - Sprite format update
6. `lua/dirquest/game.lua` - Spawn position logic

### Files Unchanged
7. `lua/dirquest/filesystem.lua` - No changes needed
8. Core mechanics all preserved

---

## Migration Path

**Current State**: v0.5.0 with side-scroller
**Target State**: v0.6.0 with top-down view

**Steps:**
1. Implement border system
2. Update player to single character
3. Create top-down directory templates
4. Update file sprites to emojis
5. Rewrite layout algorithm
6. Update renderer for borders
7. Remove ground system
8. Test all functionality

**Estimated Time**: 5-9 hours
**Breaking Changes**: Yes (visual only, mechanics preserved)
**Backward Compatible**: No (major visual redesign)

---

## Conclusion

This redesign transforms DirQuest from a side-scrolling platformer aesthetic to a traditional top-down exploration game. The change is **primarily visual** - all core mechanics (navigation, collision, interaction) are preserved but adapted to the new perspective.

The result is:
- ✅ Simpler player representation (1 char vs 3×2)
- ✅ Better space utilization (full buffer vs bottom strip)
- ✅ More intuitive top-down view
- ✅ Standardized interaction system (1-tile radius)
- ✅ Cleaner visual design with borders
- ✅ Emoji support for modern terminals
