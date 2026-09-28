#!/bin/bash
# Generates a full handoff text dump for AI assistants
cd "$(dirname "$0")"

echo "=================================================="
echo "PROJECT: MyGame — LÖVE2D Top-Down Shooter"
echo "REPO:    https://github.com/Vyrex01/MyGame"
echo "=================================================="
echo ""

echo "===== git log (last 10) ====="
git log --oneline -10
echo ""

echo "===== README.md ====="
cat README.md
echo ""

echo "===== conf.lua ====="
cat conf.lua
echo ""

echo "===== main.lua ====="
cat main.lua
echo ""

echo "===== player.lua ====="
cat player.lua
echo ""

echo "===== bullet.lua ====="
cat bullet.lua
echo ""

echo "===== enemy.lua ====="
cat enemy.lua
echo ""

echo "===== END OF HANDOFF ====="
