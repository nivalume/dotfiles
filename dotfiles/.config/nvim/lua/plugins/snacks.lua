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
      },
    },
  },
}
