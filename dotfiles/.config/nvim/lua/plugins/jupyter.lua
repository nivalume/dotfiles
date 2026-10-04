-- Jupyter notebook support in Neovim:
--   jupytext  -> edit .ipynb as Markdown (code cells delimited by ```python)
--   molten    -> run cells against a Jupyter kernel, show outputs/images
--   image.nvim -> render plot images via terminal graphics protocol
--
-- Requirements outside Neovim (installed in the active conda env):
--   pip install pynvim jupyter-client nbformat jupytext ipykernel
--   ImageMagick (`magick`) on PATH
-- Windows needs a terminal with Sixel/kitty graphics: Windows Terminal 1.22+
-- (Sixel) or WezTerm (kitty protocol).

local home = vim.uv.os_homedir()

-- Resolve the python executable used by the remote-plugin host. Prefer an
-- active conda env, fall back to the shared "jarvis" env, then to PATH.
local function python_host()
  local prefix = vim.env.CONDA_PREFIX
  if not prefix or prefix == "" then
    local candidate = vim.fs.joinpath(home, ".conda", "envs", "jarvis")
    if vim.fn.isdirectory(candidate) == 1 then
      prefix = candidate
    end
  end

  if prefix and prefix ~= "" then
    local exe = package.config:sub(1, 1) == "\\" and "python.exe" or "bin/python"
    local p = vim.fs.joinpath(prefix, exe)
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
  return vim.fn.exepath("python3") ~= "" and "python3" or "python"
end

vim.g.python3_host_prog = python_host()

-- Pick an image backend for the current terminal:
--   WezTerm/kitty -> kitty graphics protocol
--   everything else (incl. Windows Terminal) -> sixel
local function image_backend()
  if vim.env.KITTY_WINDOW_ID or vim.env.TERM == "xterm-kitty" then
    return "kitty"
  end
  if vim.env.WEZTERM_PANE or vim.env.TERM_PROGRAM == "WezTerm" then
    return "kitty"
  end
  return "sixel"
end

return {
  {
    "GCBallesteros/jupytext.nvim",
    opts = { style = "markdown", output_extension = "md", force_ft = "markdown" },
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_virt_text_output = true -- outputs stay as virtual text
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_height = 20
    end,
    config = function()
      -- The plugin is lazy-loaded, so it is missing from rtp when the build
      -- hook runs UpdateRemotePlugins. Add it now and register once.
      local plugin = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "molten-nvim")
      vim.opt.rtp:append(plugin)
      local manifest = vim.fs.joinpath(vim.fn.stdpath("data"), "rplugin.vim")
      if vim.fn.filereadable(manifest) == 0 or not vim.g._molten_rplugins_registered then
        vim.cmd("UpdateRemotePlugins")
        vim.g._molten_rplugins_registered = true
      end
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit python3<cr>", desc = "Molten: Init kernel" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten: Evaluate line" },
      { "<leader>mc", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: Evaluate operator" },
      { "<leader>mv", "vip<cmd>MoltenEvaluateVisual<cr>", mode = "x", desc = "Molten: Evaluate cell" },
      { "<leader>mr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: Re-evaluate cell" },
      { "<leader>mo", "<cmd>MoltenEnterOutput<cr>", desc = "Molten: Enter output" },
      { "<leader>md", "<cmd>MoltenDelete<cr>", desc = "Molten: Delete cell" },
    },
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = image_backend(),
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
    },
  },
}
