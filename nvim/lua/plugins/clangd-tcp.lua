-- Clangd TCP configuration for LazyVim
-- Uses remote clangd server via TCP connection instead of local Mason clangd

-- Configure clangd using Neovim 0.11+ API directly
-- This must be done at the top level, not inside a lazy.nvim opts function
vim.lsp.config("clangd", {
  cmd = { "/Users/ajay.kumar/.config/nvim/scripts/clangd-tcp-client.sh" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = {
    "compile_commands.json",
    ".clangd",
    ".git",
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
})

return {
  {
    -- Disable Mason's automatic clangd installation and startup
    "mason-org/mason-lspconfig.nvim",
    opts = {
      automatic_enable = {
        exclude = { "clangd" },
      },
    },
  },
}
