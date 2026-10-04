-- Python interpreter/conda environment selector. The chosen interpreter is
-- propagated to basedpyright and debugpy and remembered per project.
return {
  "linux-cultist/venv-selector.nvim",
  dependencies = { "neovim/nvim-lspconfig" },
  branch = "main",
  ft = "python",
  cmd = { "VenvSelect", "VenvSelectCurrent" },
  keys = {
    { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select Conda/Venv" },
  },
  opts = {
    settings = {
      options = { notify_user_on_venv_activation = true },
      search = {
        conda = {
          enable = true,
          -- Cross-platform home directory: ~/.conda/envs on every OS.
          path = vim.fs.joinpath(vim.uv.os_homedir(), ".conda", "envs"),
        },
      },
    },
  },
}
