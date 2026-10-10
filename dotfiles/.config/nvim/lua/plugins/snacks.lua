local function toggle(action)
  return { action, mode = { "i", "n" } }
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          -- .env is both a dotfile and gitignored. Toggling only `ignored`
          -- leaves it hidden, which looks like the key did nothing.
          toggle_gitignored = function(picker)
            local show = not picker.opts.ignored
            picker.opts.ignored = show
            if show then
              picker._dotfiles_before_ignored = picker.opts.hidden and true or false
              picker.opts.hidden = true
            elseif picker._dotfiles_before_ignored ~= nil then
              picker.opts.hidden = picker._dotfiles_before_ignored
            end
            picker.list:set_target()
            picker:find()
          end,
        },
        win = {
          input = {
            keys = {
              -- Dotfiles. Also bound on the list so <C-h> does not fall through
              -- to "go to left window" while the tree is focused.
              ["<C-h>"] = toggle("toggle_hidden"),
            },
          },
          list = {
            keys = {
              ["<C-h>"] = "toggle_hidden",
              ["H"] = "toggle_hidden",
              ["I"] = "toggle_gitignored",
            },
          },
        },
        sources = {
          explorer = {
            win = {
              input = {
                keys = {
                  -- Explorer-only: <C-g> is live-search in other pickers.
                  ["<C-g>"] = toggle("toggle_gitignored"),
                },
              },
              list = {
                keys = {
                  ["<C-g>"] = "toggle_gitignored",
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
