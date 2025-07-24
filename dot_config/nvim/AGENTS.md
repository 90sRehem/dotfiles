# AGENTS.md

This document provides guidelines for agentic coding agents working in this Neovim configuration repository.

## Commands

- **Lint/Format**: `stylua .`
- **Build**: No explicit build step. Neovim loads the configuration on startup.
- **Test**: No specific testing framework is set up.

## Code Style Guidelines

- **Language**: All configuration is written in Lua.
- **Formatting**: We use `stylua` with 2-space indentation and a 120-column width.
- **Structure**: This is a [LazyVim](https://lazyvim.github.io/) starter. Adhere to its structure.
  - Custom plugins are added in the `lua/plugins/` directory.
  - Each file in `lua/plugins/` should return a table of plugin specifications.
- **Naming**: Use `snake_case` for variables and filenames.
- **Imports**: Use `require("module")` to load Lua modules.
- **Error Handling**: Check for errors where appropriate, for example using `vim.v.shell_error` when making system calls.
- **Commits**: Follow conventional commit standards for commit messages.
