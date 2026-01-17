return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      shell = "zsh",
    },
    explorer = {},
    picker = {
      sources = {
        explorer = {
          layout = {
            preset = "sidebar",
            preview = false,
            layout = { width = 45 },
          },
        },
      },
      layouts = {
        default = {
          layout = {
            box = "horizontal",
            width = 0.9,
            height = 0.8,
            {
              box = "vertical",
              border = "rounded",
              title = "{source} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
            { win = "preview", border = "rounded", width = 0.6, title = "{preview}" },
          },
        },
      },
    },
  },
}
