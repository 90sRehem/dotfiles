-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Omarchy theme integration
local omarchy_theme = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(omarchy_theme) == 1 then
  vim.cmd("source " .. vim.fn.fnameescape(omarchy_theme))
end

-- Enable this option to avoid conflicts with Prettier.
vim.g.lazyvim_prettier_needs_config = true
