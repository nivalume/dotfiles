-- Jupyter notebook support in Neovim:
--   jupytext  -> edit .ipynb as Markdown (code cells delimited by ```python)
--   molten    -> run cells against a Jupyter kernel, show outputs/images
--   image.nvim -> render plot images via terminal graphics protocol
--
-- jupytext.nvim shells out to the `jupytext` executable. It does not use
-- python3_host_prog, so a conda env that has the module is not enough unless
-- that env's bin/Scripts directory is on PATH. Install the CLI with:
--   uv tool install jupytext
-- Molten still needs these in the interpreter from python_host() below:
--   pip install pynvim jupyter-client nbformat ipykernel
--   ImageMagick (`magick`) on PATH
-- Windows needs a terminal with Sixel/kitty graphics: Windows Terminal 1.22+
-- (Sixel) or WezTerm (kitty protocol).

local home = vim.uv.os_homedir()
local win = package.config:sub(1, 1) == "\\"

local function conda_prefix()
  local prefix = vim.env.CONDA_PREFIX
  if prefix and prefix ~= "" then
    return prefix
  end
  local candidate = vim.fs.joinpath(home, ".conda", "envs", "jarvis")
  if vim.fn.isdirectory(candidate) == 1 then
    return candidate
  end
end

-- Resolve the python executable used by the remote-plugin host. Prefer an
-- active conda env, fall back to the shared "jarvis" env, then to PATH.
local function python_host()
  local prefix = conda_prefix()
  if prefix then
    local exe = win and "python.exe" or "bin/python"
    local p = vim.fs.joinpath(prefix, exe)
    if vim.fn.filereadable(p) == 1 then
      return p
    end
  end
  return vim.fn.exepath("python3") ~= "" and "python3" or "python"
end

-- jupytext.nvim always runs `jupytext`. Prefer a PATH install, then the CLI
-- next to the conda interpreter used above.
local function ensure_jupytext()
  if vim.fn.executable("jupytext") == 1 then
    return true
  end
  local prefix = conda_prefix()
  if not prefix then
    return false
  end
  local dir = vim.fs.joinpath(prefix, win and "Scripts" or "bin")
  local name = win and "jupytext.exe" or "jupytext"
  if vim.fn.filereadable(vim.fs.joinpath(dir, name)) ~= 1 then
    return false
  end
  vim.env.PATH = dir .. (win and ";" or ":") .. (vim.env.PATH or "")
  return vim.fn.executable("jupytext") == 1
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
    config = function(_, opts)
      if not ensure_jupytext() then
        vim.notify(
          "jupytext CLI not found, so .ipynb opens as JSON. Install it with `uv tool install jupytext`.",
          vim.log.levels.WARN
        )
        return
      end
      require("jupytext").setup(opts)
      -- A failed conversion calls error() inside BufReadCmd. Snacks opens files
      -- through nvim_exec2, which surfaces that as E5108. Keep the file readable.
      local cmds = vim.api.nvim_get_autocmds({ group = "jupytext-nvim", event = "BufReadCmd" })
      vim.api.nvim_clear_autocmds({ group = "jupytext-nvim", event = "BufReadCmd" })
      for _, cmd in ipairs(cmds) do
        if cmd.callback then
          local read_ipynb = cmd.callback
          vim.api.nvim_create_autocmd("BufReadCmd", {
            pattern = cmd.pattern,
            group = "jupytext-nvim",
            desc = "Read .ipynb via jupytext, fall back to raw JSON",
            callback = function(ev)
              local ok, err = pcall(read_ipynb, ev)
              if ok then
                return
              end
              vim.notify("jupytext failed, opening the raw notebook:\n" .. tostring(err), vim.log.levels.ERROR)
              vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.readfile(ev.match))
              vim.bo.filetype = "json"
            end,
          })
        end
      end
    end,
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
      local host = vim.g.python3_host_prog
      if host and vim.fn.executable(host) == 1 then
        vim.fn.system({ host, "-c", "import pynvim" })
        if vim.v.shell_error ~= 0 then
          vim.notify(
            "Molten needs pynvim in " .. host .. ":\n  " .. host .. " -m pip install pynvim nbformat",
            vim.log.levels.ERROR
          )
          return
        end
      end
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
      { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Molten: Choose kernel" },
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
