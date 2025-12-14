return {
  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = true, -- Load only when needed (not the default colorscheme)
    priority = 900, -- Lower priority than catppuccin
    config = function()
      require('github-theme').setup({
        -- ...
      })
    end,
  },
}
