return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep files" },
      { "<leader>fG", function() Snacks.picker.git_files() end, desc = "Find Git files" },
    },
    opts = {
      picker = {
        actions = {
          toggle_dotfiles_and_ignored = function(picker)
            local show = not picker.opts.ignored
            picker.opts.ignored = show
            if show then
              picker._dotc_previous_hidden = picker.opts.hidden == true
              picker.opts.hidden = true
            elseif picker._dotc_previous_hidden ~= nil then
              picker.opts.hidden = picker._dotc_previous_hidden
              picker._dotc_previous_hidden = nil
            end
            picker.list:set_target()
            picker:find()
          end,
        },
        win = {
          input = { keys = { ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } } } },
          list = { keys = { ["<C-h>"] = "toggle_hidden", ["I"] = "toggle_dotfiles_and_ignored" } },
        },
        sources = {
          explorer = {
            win = {
              input = { keys = { ["<C-g>"] = { "toggle_dotfiles_and_ignored", mode = { "i", "n" } } } },
              list = { keys = { ["<C-g>"] = "toggle_dotfiles_and_ignored", ["Y"] = { "yank_relative", mode = { "n", "x" } } } },
            },
            actions = {
              yank_relative = function(picker)
                local cwd, paths = picker:cwd(), {}
                if vim.fn.mode():find("^[vV]") then
                  picker.list:select()
                end
                for _, item in ipairs(picker:selected({ fallback = true })) do
                  local path = Snacks.picker.util.path(item)
                  if path then
                    table.insert(paths, vim.fs.relpath(cwd, path) or path)
                  end
                end
                if #paths > 0 then
                  local register = vim.v.register == '"' and "+" or vim.v.register
                  vim.fn.setreg(register, paths, "l")
                  Snacks.notify.info(table.concat(paths, "\n"))
                end
                picker.list:set_selected()
              end,
            },
          },
        },
      },
    },
  },
}
