vim.keymap.set("n", "<leader>tw", "<cmd>setlocal wrap!<cr>", { desc = "Toggle line wrap" })
vim.keymap.set("t", "<S-Esc>", function()
  Snacks.zen.zoom()
end, { desc = "Toggle terminal zoom" })
