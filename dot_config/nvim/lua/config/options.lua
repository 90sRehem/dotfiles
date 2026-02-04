-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set shell to zsh
vim.o.shell = "/usr/bin/zsh"

vim.cmd([[
  highlight RainbowDelimiterRed guifg=#E06C75
  highlight RainbowDelimiterYellow guifg=#E5C07B
  highlight RainbowDelimiterBlue guifg=#61AFEF
  highlight RainbowDelimiterOrange guifg=#D19A66
  highlight RainbowDelimiterGreen guifg=#98C379
  highlight RainbowDelimiterViolet guifg=#C678DD
  highlight RainbowDelimiterCyan guifg=#56B6C2
]])

-- Enable this option to avoid conflicts with Prettier.
vim.g.lazyvim_prettier_needs_config = true
