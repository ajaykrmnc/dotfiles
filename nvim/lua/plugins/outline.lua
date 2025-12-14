return {
  "hedyhli/outline.nvim",

  opts = {
    outline_window = {
      width = 30,
    },
    keymaps = {},
  },

  config = function(_, opts)
    -- Example mapping to toggle outline
    vim.keymap.set("n", "<leader>ou", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
    require("outline").setup(opts)
  end,
}
