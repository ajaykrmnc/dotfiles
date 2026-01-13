-- Minimal LSP Configuration
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    "b0o/schemastore.nvim", -- JSON schemas for better validation
  },
  opts = {
    -- Configure servers here to override LazyVim defaults
    servers = {
      -- Clangd with query-driver for cross-compilation
      clangd = {
        cmd = {
          "clangd",
          "-j=48",
          "--clang-tidy=false",
          -- Query driver pattern matching .clangd config file
          "--query-driver=/Users/ajay.kumar/garage/workspace/ap/build/export/toolchain-*/bin/*,/Users/ajay.kumar/garage/workspace/ap/build/export/arm-gnu-toolchain-*/bin/*",
          "--background-index",
          -- Compile commands database location
          "--compile-commands-dir=/Users/ajay.kumar/garage/workspace/ap",
          -- Enable more detailed logging for debugging
          "--log=verbose",
        },
        -- Set root directory to where .clangd config file is located
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern(".clangd", "compile_commands.json", ".git")(fname) or util.path.dirname(fname)
        end,
      },
    },
  },
  config = function(_, opts)
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    -- Basic diagnostic configuration
    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- Get capabilities from blink.cmp for proper LSP integration
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.positionEncodings = { "utf-8", "utf-16" }

    -- Try to get blink.cmp capabilities if available
    local has_blink, blink = pcall(require, "blink.cmp")
    if has_blink then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    -- Simple on_attach function
    local on_attach = function(client, bufnr)
      -- Basic editor settings
      vim.bo[bufnr].expandtab = true
      vim.bo[bufnr].tabstop = 2
      vim.bo[bufnr].shiftwidth = 2

      -- Disable formatting for specific servers (use external formatters)
      if client.name == "ts_ls" or client.name == "jsonls" or client.name == "cssls" or client.name == "html" then
        client.server_capabilities.documentFormattingProvider = false
      end
    end

    -- Server list
    local servers = {
      "ts_ls",
      "eslint",
      "jsonls",
      "cssls",
      "html",
      "lua_ls",
      "angularls",
      "marksman",
      "clangd",
    }

    mason_lspconfig.setup({
      ensure_installed = servers,
      handlers = {
        -- Default handler for all servers
        function(server_name)
          -- Skip if custom config exists in opts.servers
          if opts.servers and opts.servers[server_name] then
            return
          end
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,

        -- Clangd with custom configuration
        ["clangd"] = function()
          lspconfig.clangd.setup(vim.tbl_deep_extend("force", {
            on_attach = on_attach,
            capabilities = capabilities,
          }, opts.servers and opts.servers["clangd"] or {}))
        end,

        -- Angular Language Server - Fixed for TypeScript resolution
        ["angularls"] = function()
          if opts.servers and opts.servers["angularls"] then
            return
          end
          local mason_path = vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules"

          lspconfig.angularls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = { "typescript", "html", "typescriptreact" },
            root_dir = lspconfig.util.root_pattern("angular.json", "project.json"),
            cmd = {
              "ngserver",
              "--stdio",
              "--tsProbeLocations",
              mason_path,
              "--ngProbeLocations",
              mason_path,
            },
          })
        end,

        -- Lua LSP with basic Neovim setup
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
              },
            },
          })
        end,

        -- JSON LSP with schema support
        ["jsonls"] = function()
          lspconfig.jsonls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              json = {
                schemas = require("schemastore").json.schemas(),
                validate = { enable = true },
              },
            },
          })
        end,
      },
    })
  end,
}
