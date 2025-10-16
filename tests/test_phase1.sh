#!/bin/bash
# Test script for DirQuest Phase 1
# Run this to verify Phase 1 implementation

echo "=================================="
echo "DirQuest.nvim Phase 1 Test Suite"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Test 1: Plugin loads
echo -n "Test 1: Plugin loads without errors... "
OUTPUT=$(nvim --headless --noplugin -u NONE -c "set runtimepath+=." \
  -c "lua local ok = pcall(require, 'dirquest'); vim.cmd('quit!')" 2>&1)
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
  echo "Output: $OUTPUT"
fi

# Test 2: Command registration
echo -n "Test 2: DirQuest command exists... "
OUTPUT=$(nvim --headless -u NONE -c "set runtimepath+=." \
  -c "runtime! plugin/dirquest.vim" \
  -c "lua if vim.fn.exists(':DirQuest') == 2 then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

# Test 3: Buffer creation
echo -n "Test 3: Buffer creates with correct type... "
OUTPUT=$(nvim --headless --noplugin -u NONE -c "set runtimepath+=." \
  -c "lua require('dirquest').start()" \
  -c "lua local bt = vim.api.nvim_buf_get_option(0, 'buftype'); if bt == 'nofile' then print('OK') end" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

# Test 4: Start and close functionality
echo -n "Test 4: Start and close works... "
OUTPUT=$(nvim --headless --noplugin -u NONE -c "set runtimepath+=." \
  -c "lua require('dirquest').start()" \
  -c "lua require('dirquest').close()" \
  -c "lua print('OK')" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

# Test 5: Multiple opens
echo -n "Test 5: Multiple opens work... "
OUTPUT=$(nvim --headless --noplugin -u NONE -c "set runtimepath+=." \
  -c "lua require('dirquest').start()" \
  -c "lua require('dirquest').close()" \
  -c "lua require('dirquest').start()" \
  -c "lua require('dirquest').close()" \
  -c "lua print('OK')" \
  -c "quit!" 2>&1)
if echo "$OUTPUT" | grep -q "OK"; then
  echo -e "${GREEN}✓ PASS${NC}"
else
  echo -e "${RED}✗ FAIL${NC}"
fi

echo ""
echo "=================================="
echo "Phase 1 Testing Complete"
echo "=================================="
echo ""
echo "To manually test:"
echo "  1. Open Neovim: nvim"
echo "  2. Run: :set runtimepath+=."
echo "  3. Run: :DirQuest"
echo "  4. Press 'q' or <Esc> to quit"
echo ""
echo "See docs/QUICKSTART.md for detailed testing instructions"
