-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- open a new empty buffer
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "Novo buffer vazio" })

-- Forçar LSP commands para usar fzf-lua ao invés do padrão
vim.keymap.set("n", "grr", function()
  require("fzf-lua").lsp_references()
end, { desc = "LSP References (fzf-lua)" })

vim.keymap.set("n", "gr", function()
  require("fzf-lua").lsp_references()
end, { desc = "LSP References (fzf-lua)", nowait = true })

vim.keymap.set("n", "gd", function()
  require("fzf-lua").lsp_definitions()
end, { desc = "LSP Definitions (fzf-lua)" })

-- Vai para a definição em uma split vertical
vim.keymap.set("n", "gv", function()
  vim.cmd("vsplit") -- Abre uma vertical split
  vim.lsp.buf.definition() -- Vai para a definição com LSP
end, { desc = "Go to definition in vertical split" })

-- VISUAL MODE
-- move selected block of text up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected block down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected block up" })

-- Telescope symbols search
vim.keymap.set("n", "<leader>fs", ":Telescope lsp_document_symbols<CR>", { desc = "Find symbols in document" })

--  Scroll half page up/down centralize the cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll half page up" })
