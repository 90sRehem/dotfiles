-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- open a new empty buffer
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "Novo buffer vazio" })
-- Vai para a definição em uma split vertical
vim.keymap.set("n", "gv", function()
  vim.cmd("vsplit") -- Abre uma vertical split
  vim.lsp.buf.definition() -- Vai para a definição com LSP
end, { desc = "Go to definition in vertical split" })

-- VISUAL MODE
-- move selected block of text up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected block down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected block up" })
