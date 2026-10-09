return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["H"] = "toggle_hidden",
              ["I"] = "toggle_ignored",
            },
          },
        },
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["Y"] = { "yank_relative", mode = { "n", "x" } },
                },
              },
            },
            actions = {
              -- Absolute path stays on `y`. This is relative to the explorer root.
              yank_relative = function(picker)
                local cwd = picker:cwd()
                local files = {}
                if vim.fn.mode():find("^[vV]") then
                  picker.list:select()
                end
                for _, item in ipairs(picker:selected({ fallback = true })) do
                  local abs = Snacks.picker.util.path(item)
                  local rel = abs and vim.fs.relpath(cwd, abs) or abs
                  if rel then
                    table.insert(files, rel)
                  end
                end
                picker.list:set_selected()
                local value = table.concat(files, "\n")
                vim.fn.setreg(vim.v.register or "+", value, "l")
                Snacks.notify.info(value)
              end,
            },
          },
        },
      },
    },
  },
}
