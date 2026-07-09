-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_auto_comment", {}),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- auto reload file when changed externally
vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
  group = vim.api.nvim_create_augroup("auto_reload", {}),
  callback = function(args)
    vim.cmd("checktime " .. args.buf)
  end,
})

-- Force omarchy theme after startup (overrides session restore)
vim.api.nvim_create_autocmd("User", {
  pattern = "LazySync",
  group = vim.api.nvim_create_augroup("omarchy_theme", {}),
  callback = function()
    local omarchy_theme = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
    if vim.fn.filereadable(omarchy_theme) == 1 then
      local f = io.open(omarchy_theme, "r")
      if f then
        local content = f:read("*a")
        f:close()
        for cs in content:gmatch('colorscheme%s*=%s*"([^"]+)"') do
          vim.cmd.colorscheme(cs)
          return
        end
      end
    end
  end,
})
