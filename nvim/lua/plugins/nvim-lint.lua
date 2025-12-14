-- lua/plugins/nvim-lint.lua
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      -- Disable eslint_d since we're using ESLint LSP
      -- javascript = { "eslint_d" },
      -- typescript = { "eslint_d" },
      -- typescriptreact = { "eslint_d" },
      -- json = { "eslint_d" },
      scss = { "stylelint" },
      css = { "stylelint" },
      python = { "flake8" },
      sh = { "shellcheck" },
    },
  },
  config = function(_, opts)
    local lint = require("lint")
    lint.linters_by_ft = opts.linters_by_ft

    -- Temporarily disable all linting to debug ESLint issues
    -- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    --   callback = function()
    --     lint.try_lint()
    --   end,
    -- })
  end,
}
