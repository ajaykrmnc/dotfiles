-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Exit terminal mode with <Esc>
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>cf", function() require("conform").format() end, { desc = "Format with conform" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>echo expand('%:p')<CR>", { desc = "Display File Name" })

-- Simple diagnostic keymaps
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostic" })

-- Augment AI Assistant keymaps
vim.keymap.set("n", "<leader>ac", "<cmd>Augment chat<CR>", { desc = "Augment chat" })
vim.keymap.set("v", "<leader>ac", "<cmd>Augment chat<CR>", { desc = "Augment chat" })
vim.keymap.set("n", "<leader>an", "<cmd>Augment chat-new<CR>", { desc = "Augment chat-new" })
vim.keymap.set("n", "<leader>at", "<cmd>Augment chat-toggle<CR>", { desc = "Augment chat-toggle" })
vim.keymap.set("n", "<leader>to", "<cmd>terminal<CR>", { desc = "Open terminal" })
