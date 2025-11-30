# Taskmaster Project Template

This is a cookiecutter template for setting up Taskmaster in a new project with best practices, workflows, and helper scripts.

## What's Included

- **Taskmaster workflow rules** - Comprehensive guides for AI agents and developers
- **Git worktree integration** - Scripts and rules for parallel feature development
- **Helper scripts** - Utilities for watching tasks and managing worktrees
- **Makefile targets** - Convenient commands for common Taskmaster operations
- **PRD templates** - Example templates for Product Requirements Documents

## Usage

### Requirements

Clone task-master-cookiecutter

### With Cookiecutter (if hydration needed)

Install cookiecutter - optional, but suggested because faster than manual replacement.

```bash
pip install cookiecutter
```

```bash
cookiecutter https://github.com/Davz33/task-master-cookiecutter
```

### Manual Setup

1. Copy the template files to your project
2. Replace `{{ project_name }}` with your actual project name
3. Customize branch naming conventions if needed
4. Update Makefile with project-specific commands

## Template Variables

The following variables need to be replaced when using this template:

- `{{ project_name }}` - Your project name (e.g., "myapp")
  - Note: Worktree prefix is auto-generated from this (sanitized: lowercase, hyphens, no special chars)
- `{{ default_branch }}` - Default git branch (usually "main" or "master")
- `{{ branch_prefix }}` - Feature branch prefix (usually "feature/")

## Structure

```
.cursor/rules/taskmaster/  - Taskmaster workflow and command reference rules
scripts/                    - Helper scripts for Taskmaster and git worktrees
.taskmaster/               - Taskmaster configuration and templates
Makefile                   - Convenience targets for Taskmaster operations
```

