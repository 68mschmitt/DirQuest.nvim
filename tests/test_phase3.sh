#!/bin/bash

echo "=================================="
echo "DirQuest.nvim Phase 3 Test Suite"
echo "=================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -n "Test 3.1: Player module loads... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local player = require('dirquest.player'); if player then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 3.2: Player has default sprite... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local player = require('dirquest.player'); if player.default_sprite and #player.default_sprite == 2 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 3.3: Player initializes with position... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local player = require('dirquest.player'); player.init(); local x, y = player.get_position(); if x and y then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 3.4: Player can move... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local player = require('dirquest.player'); player.init(10, 10); local moved = player.move('right', 100, 100); if moved then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 3.5: Player respects boundaries... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local player = require('dirquest.player'); player.init(0, 0); local moved = player.move('left', 100, 100); if not moved then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 3.6: DirQuest starts with player... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "runtime! plugin/dirquest.vim" \
  -c "lua require('dirquest').start()" \
  -c "lua local player = require('dirquest.player'); if player.state.x and player.state.y then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 3.7: Movement in all directions... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local player = require('dirquest.player'); player.init(50, 50); local r = player.move('right', 100, 100); local l = player.move('left', 100, 100); local u = player.move('up', 100, 100); local d = player.move('down', 100, 100); if r and l and u and d then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo ""
echo "=================================="
echo "Phase 3 Testing Complete"
echo "=================================="
echo ""
echo "Manual testing steps:"
echo "  1. Open Neovim: nvim"
echo "  2. Run: :set runtimepath+=."
echo "  3. Run: :DirQuest"
echo "  4. You should see a player sprite ( o and /|\\)"
echo "  5. Press h, j, k, l to move the player"
echo "  6. Player should move smoothly in all directions"
echo "  7. Player should stop at buffer boundaries"
echo "  8. Press q to quit"
echo ""
echo "See docs/QUICKSTART.md for detailed testing instructions"
