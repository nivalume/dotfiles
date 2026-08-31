-- Autocmds are automatically loaded on the VeryLazy event
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("dotfiles_highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
