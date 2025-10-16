#!/bin/bash

echo "=================================="
echo "DirQuest.nvim Phase 4 Test Suite"
echo "=================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -n "Test 4.1: ASCII art module loads... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local art = require('dirquest.ascii_art'); if art then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 4.2: World module loads... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local world = require('dirquest.world'); if world then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 4.3: Directory art templates exist... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local art = require('dirquest.ascii_art'); if art.directory_templates.small and art.directory_templates.medium and art.directory_templates.large then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 4.4: Generate directory art... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local art = require('dirquest.ascii_art'); local dir_art = art.get_directory_art('test', 3); if dir_art and #dir_art > 0 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 4.5: Generate world with dimensions... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local world = require('dirquest.world'); local w = world.generate_world(100, 50); if w.width == 100 and w.height == 50 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 4.6: World has ground level... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local world = require('dirquest.world'); local w = world.generate_world(100, 50); if w.ground_level then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 4.7: DirQuest renders world with structures... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "runtime! plugin/dirquest.vim" \
  -c "lua require('dirquest').start()" \
  -c "lua local renderer = require('dirquest.renderer'); if renderer.current_world then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo ""
echo "=================================="
echo "Phase 4 Testing Complete"
echo "=================================="
echo ""
echo "Manual testing steps:"
echo "  1. Open Neovim: nvim"
echo "  2. Run: :set runtimepath+=."
echo "  3. Run: :DirQuest"
echo "  4. You should see ASCII art boxes representing directories"
echo "  5. You should see a ground line (===)"
echo "  6. File sprites should appear as [L], [T], [F], etc."
echo "  7. Move player with hjkl around the world"
echo "  8. Walk into a directory box and press Enter to enter it"
echo "  9. Press q to quit"
echo ""
echo "See docs/QUICKSTART.md for detailed testing instructions"
