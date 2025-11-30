#!/bin/bash

# Git Worktree Setup Script
# Creates a worktree for a feature branch and sets up the taskmaster tag

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the repository root
repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

# Function to show usage
usage() {
    echo "Usage: $0 <branch-name> [tag-name]"
    echo ""
    echo "Creates a git worktree for a feature branch and optionally sets up a taskmaster tag."
    echo ""
    echo "Arguments:"
    echo "  branch-name  Name of the feature branch (e.g., {{ branch_prefix }}websocket-server)"
    echo "  tag-name     Optional taskmaster tag name (defaults to branch name with '{{ branch_prefix }}' prefix removed)"
    echo ""
    echo "Examples:"
    echo "  $0 {{ branch_prefix }}websocket-server feature-websocket"
    echo "  $0 {{ branch_prefix }}timeline-component"
    echo ""
    exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
    usage
fi

BRANCH_NAME="$1"
TAG_NAME="${2:-${BRANCH_NAME#{{ branch_prefix }}}}"

# Validate branch name
if [[ ! "$BRANCH_NAME" =~ ^{{ branch_prefix }} ]]; then
    echo -e "${YELLOW}Warning: Branch name doesn't start with '{{ branch_prefix }}'. Continuing anyway...${NC}"
fi

# Check if branch exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo -e "${BLUE}Branch '$BRANCH_NAME' already exists.${NC}"
else
    echo -e "${BLUE}Creating branch '$BRANCH_NAME'...${NC}"
    git checkout -b "$BRANCH_NAME" 2>/dev/null || {
        echo -e "${YELLOW}Branch creation failed. It may already exist remotely.${NC}"
    }
    # Switch back to default branch
    git checkout {{ default_branch }} 2>/dev/null || git checkout master 2>/dev/null || true
fi

# Determine worktree directory name
# Auto-generate worktree prefix from project name (sanitized for git worktree compatibility)
# Git worktree names should be lowercase, use hyphens, and avoid special characters
# Using shell to sanitize: lowercase, replace spaces/underscores with hyphens, remove invalid chars
PROJECT_NAME_SANITIZED=$(echo "{{ cookiecutter.project_name }}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
WORKTREE_DIR="../${PROJECT_NAME_SANITIZED}-${BRANCH_NAME#{{ branch_prefix }}}"

# Check if worktree already exists
if [ -d "$WORKTREE_DIR" ]; then
    echo -e "${YELLOW}Worktree directory '$WORKTREE_DIR' already exists.${NC}"
    echo -e "${BLUE}Switching to existing worktree...${NC}"
    cd "$WORKTREE_DIR"
else
    echo -e "${BLUE}Creating worktree at '$WORKTREE_DIR'...${NC}"
    git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
    cd "$WORKTREE_DIR"
fi

# Set up taskmaster tag if tag name provided
if [ -n "$TAG_NAME" ]; then
    echo -e "${BLUE}Setting up taskmaster tag '$TAG_NAME'...${NC}"
    
    # Check if tag exists
    if task-master tags 2>/dev/null | grep -q "$TAG_NAME"; then
        echo -e "${GREEN}Tag '$TAG_NAME' already exists.${NC}"
    else
        echo -e "${BLUE}Creating tag '$TAG_NAME'...${NC}"
        task-master add-tag "$TAG_NAME" -d "Tasks for $BRANCH_NAME" 2>/dev/null || {
            echo -e "${YELLOW}Tag creation failed or already exists.${NC}"
        }
    fi
    
    # Switch to the tag
    task-master use-tag "$TAG_NAME" 2>/dev/null || {
        echo -e "${YELLOW}Failed to switch to tag '$TAG_NAME'.${NC}"
    }
fi

echo ""
echo -e "${GREEN}✓ Worktree setup complete!${NC}"
echo ""
echo -e "${BLUE}Worktree location:${NC} $WORKTREE_DIR"
echo -e "${BLUE}Branch:${NC} $BRANCH_NAME"
if [ -n "$TAG_NAME" ]; then
    echo -e "${BLUE}Taskmaster tag:${NC} $TAG_NAME"
fi
echo ""
echo -e "${BLUE}To work in this worktree:${NC}"
echo "  cd $WORKTREE_DIR"
echo ""
echo -e "${BLUE}To remove this worktree when done:${NC}"
echo "  git worktree remove $WORKTREE_DIR"
echo ""

