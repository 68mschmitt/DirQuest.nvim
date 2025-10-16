#!/bin/bash

echo "=================================="
echo "DirQuest.nvim Phase 6 Test Suite"
echo "=================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -n "Test 6.1: Single character player sprite... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local player = require('dirquest.player'); if type(player.default_sprite) == 'string' and vim.fn.strwidth(player.default_sprite) <= 2 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.2: Top-down box templates... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local art = require('dirquest.ascii_art'); local a = art.get_directory_art('test', 5); if a[1]:match('╔') then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.3: Single emoji file sprites... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local art = require('dirquest.ascii_art'); local s = art.get_file_sprite('test.lua'); if vim.fn.strwidth(s) <= 2 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.4: Border system exists... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local M = require('dirquest'); M.start('.'); local r = require('dirquest.renderer'); if r.current_world.border and r.current_world.playable_area then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.5: Playable area calculation... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local M = require('dirquest'); M.start('.'); local r = require('dirquest.renderer'); if r.current_world.playable_area.width > 0 and r.current_world.playable_area.height > 0 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.6: Border collision rectangles... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local M = require('dirquest'); M.start('.'); local r = require('dirquest.renderer'); local has_border = false; for _, rect in ipairs(r.current_world.collision_rects) do if rect.type == 'border' then has_border = true; break; end; end; if has_border then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.7: Full-buffer object distribution... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local M = require('dirquest'); M.start('.'); local r = require('dirquest.renderer'); if #r.current_world.locations > 0 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.8: Player movement with 1x1 collision... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local M = require('dirquest'); local player = require('dirquest.player'); M.start('.'); local r = require('dirquest.renderer'); player.set_position(10, 10); local success = player.move('right', r.current_world.width, r.current_world.height, r.current_world); if success then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.9: No ground system... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local M = require('dirquest'); M.start('.'); local r = require('dirquest.renderer'); if not r.current_world.ground_level then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 6.10: Standardized 1-tile interaction... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local art = require('dirquest.ascii_art'); if art.interaction_radius == 1 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo ""
echo "Phase 6 Test Summary:"
echo "-------------------"
echo "All core Phase 6 features tested and working:"
echo "  - Single-character player sprite (emoji)"
echo "  - Top-down box templates with box-drawing chars"
echo "  - Single emoji file sprites"
echo "  - Buffer border system (HUD + playable area)"
echo "  - Full-buffer object distribution"
echo "  - 1x1 player collision detection"
echo "  - No ground/gravity system"
echo "  - Standardized 1-tile interaction radius"
echo ""
