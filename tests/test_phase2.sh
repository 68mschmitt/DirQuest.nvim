#!/bin/bash

echo "=================================="
echo "DirQuest.nvim Phase 2 Test Suite"
echo "=================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo -n "Test 2.1: Display current directory... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "runtime! plugin/dirquest.vim" \
  -c "lua require('dirquest').start()" \
  -c "lua local game = require('dirquest.game'); if game.state.current_dir then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 2.2: List directory contents... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "runtime! plugin/dirquest.vim" \
  -c "lua require('dirquest').start()" \
  -c "lua local game = require('dirquest.game'); if game.state.items then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 2.3: Read specific directory... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "runtime! plugin/dirquest.vim" \
  -c "lua require('dirquest').start('/tmp')" \
  -c "lua local game = require('dirquest.game'); if game.state.current_dir == '/tmp' then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 2.4: Distinguish files and directories... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "runtime! plugin/dirquest.vim" \
  -c "lua require('dirquest').start()" \
  -c "lua local game = require('dirquest.game'); if game.state.items.directories and game.state.items.files then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo -n "Test 2.5: Filesystem module functions exist... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "lua local fs = require('dirquest.filesystem'); if fs.read_directory and fs.is_directory and fs.get_parent_directory then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo ""
echo "=================================="
echo "Phase 2 Testing Complete"
echo "=================================="
echo ""
echo "Manual testing steps:"
echo "  1. Open Neovim: nvim"
echo "  2. Run: :set runtimepath+=."
echo "  3. Run: :DirQuest"
echo "  4. You should see a list of directories and files"
echo "  5. Navigate with j/k, press Enter to open a directory"
echo "  6. Press - to go to parent directory"
echo "  7. Press q to quit"
echo ""
echo "See docs/QUICKSTART.md for detailed testing instructions"
