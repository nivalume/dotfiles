local windows = vim.uv.os_uname().sysname == "Windows_NT"
local home = vim.uv.os_homedir()
local envs = vim.fs.joinpath(home, "miniforge3", "envs")
local base = vim.fs.joinpath(home, "miniforge3", windows and "" or "bin")
local user_envs = vim.fs.joinpath(home, ".conda", "envs")
local pattern = windows and "python.exe$" or "'/bin/python$'"
local options = " --no-ignore-vcs --full-path --color never -L"

local function search(path)
  return { command = "$FD " .. pattern .. " " .. vim.fn.shellescape(path) .. options, type = "anaconda" }
end

return {
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      search = {
        miniforge_envs = search(envs),
        miniforge_base = search(base),
        conda_user_envs = search(user_envs),
      },
    },
  },
}
