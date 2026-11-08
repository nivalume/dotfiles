-- Run after bootstrapping the LazyVim plugins in an isolated Neovim data directory.
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
assert(vim.o.scrolloff == 8, "scrolloff preference was not loaded")

local plugins = require("lazy.core.config").plugins
local values = require("lazy.core.plugin").values
local python = values(assert(plugins["venv-selector.nvim"]), "opts", false)
local conda = assert(python.search.miniforge_envs)
assert(conda.type == "anaconda" and conda.command:find("miniforge3", 1, true), "Miniforge search is missing")

local rust = values(assert(plugins["rustaceanvim"]), "opts", false).server.default_settings["rust-analyzer"]
assert(rust.cargo.targetDir == true and rust.cargo.allTargets == false and rust.check.workspace == false, "Rust settings are missing")

local picker = values(assert(plugins["snacks.nvim"]), "opts", false).picker
local toggle = assert(picker.actions.toggle_dotfiles_and_ignored)
local mock = { opts = { ignored = false, hidden = false }, list = { set_target = function() end }, find = function() end }
toggle(mock)
assert(mock.opts.ignored and mock.opts.hidden, "ignored files should be visible")
toggle(mock)
assert(not mock.opts.ignored and not mock.opts.hidden, "hidden-file preference should be restored")
assert(type(picker.sources.explorer.actions.yank_relative) == "function", "relative path action is missing")
assert(vim.fn.maparg("<leader>fg", "n", false, true).desc == "Grep files", "legacy grep mapping is missing")
assert(not plugins["molten-nvim"] and not plugins["jupytext.nvim"], "Jupyter was not selected")

print("Neovim configuration checks passed")
