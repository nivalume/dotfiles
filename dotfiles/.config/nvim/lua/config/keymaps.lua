-- Keymaps are loaded on the VeryLazy event. The remaining leader mappings are
-- provided by LazyVim (press <leader> to discover them through which-key).
local map = vim.keymap.set

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

map("n", "<leader>tw", "<cmd>setlocal wrap!<cr>", { desc = "Toggle line wrap" })
