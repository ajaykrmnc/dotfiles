-- lua/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  opts = {
    format_on_save = false,
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      html = { "prettier" },
      scss = { "prettier" },
      css = { "prettier" },
      markdown = { "prettier" },
      python = { "black" },
      sh = { "shfmt" },
      groovy = { "npm-groovy-lint" }, -- via external binary
      stylus = { "prettier" },
    },
  },
  -- IMPORTANT: Configure the underlying formatters (e.g., stylua, prettier, black, shfmt)
  -- to respect the exclude patterns defined in config/excludes.lua.
  -- This typically involves creating or modifying configuration files
  -- for each formatter (e.g., .prettierignore, .styluaignore, etc.).
}
