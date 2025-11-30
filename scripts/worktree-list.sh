#!/bin/bash

# List all git worktrees

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the repository root
repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

echo -e "${BLUE}Git Worktrees:${NC}"
echo ""

git worktree list

echo ""
echo -e "${BLUE}To remove a worktree:${NC}"
echo "  git worktree remove <path>"
echo ""
echo -e "${BLUE}To create a new worktree:${NC}"
echo "  ./scripts/worktree-setup.sh <branch-name> [tag-name]"
echo ""

