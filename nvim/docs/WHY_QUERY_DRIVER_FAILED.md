# Why --query-driver Was Not Working

## TL;DR

**You were using LazyVim, but configuring LSP like it was standalone nvim-lspconfig.**

LazyVim requires a different configuration pattern. Your old config was being completely ignored because LazyVim's own LSP setup ran first and didn't know about your custom handlers.

## The Configuration Mismatch

### What You Had (Wrong for LazyVim)

```lua
-- This pattern works for STANDALONE nvim-lspconfig
-- But NOT for LazyVim!
return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")
    
    mason_lspconfig.setup({
      handlers = {
        ["clangd"] = function()
          lspconfig.clangd.setup({
            cmd = { "clangd", "--query-driver=...", ... }
          })
        end,
      }
    })
  end,
}
```

**Why it failed:**
1. LazyVim loads its own `nvim-lspconfig` plugin from `lazyvim.plugins`
2. LazyVim's plugin runs **before** your custom config
3. LazyVim sets up clangd with default settings
4. Your `mason_lspconfig.handlers` run **after**, but the server is already configured
5. Result: Your custom `cmd` array is ignored

### What You Need (Correct for LazyVim)

```lua
-- This pattern works for LazyVim
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = { "clangd", "--query-driver=...", ... }
      },
    },
  },
}
```

**Why it works:**
1. LazyVim's LSP plugin has an `opts` function that returns default config
2. Your `opts` table is **deep-merged** with LazyVim's defaults
3. LazyVim's config function reads from the merged `opts.servers` table
4. LazyVim calls `lspconfig.clangd.setup()` with your custom `cmd` array
5. Result: Your custom flags are used!

## The Plugin Loading Order

### LazyVim Plugin Loading Sequence

```
1. lazy.nvim bootstrap
2. LazyVim core loads
3. LazyVim imports "lazyvim.plugins" (includes LSP config)
4. Your custom plugins in lua/plugins/ load
5. Configs are merged (opts tables are deep-merged)
6. Plugins initialize in dependency order
7. LSP servers are configured using merged opts
```

### Why Your Old Config Was Ignored

```
LazyVim's lspconfig plugin:
  ├─ Has opts function that returns default servers
  ├─ Has config function that sets up servers
  └─ Runs BEFORE your custom config

Your old lspconfig.lua:
  ├─ Has config function with mason_lspconfig.handlers
  ├─ Tries to setup clangd again
  └─ But LazyVim already configured it!
```

## How LazyVim Merges Configurations

LazyVim uses `vim.tbl_deep_extend` to merge your `opts` with its defaults:

```lua
-- LazyVim's default opts
{
  servers = {
    clangd = {},  -- Empty, uses defaults
  }
}

-- Your custom opts
{
  servers = {
    clangd = {
      cmd = { "clangd", "--query-driver=...", ... }
    }
  }
}

-- Merged result (what LazyVim uses)
{
  servers = {
    clangd = {
      cmd = { "clangd", "--query-driver=...", ... }  -- Your custom cmd!
    }
  }
}
```

## The Fix Applied

1. **Created** `lspconfig-lazyvim.lua` with LazyVim-compatible `opts` pattern
2. **Disabled** old `lspconfig.lua` that used standalone pattern
3. **Result**: LazyVim now merges your custom clangd config and uses it

## Verification

After the fix, `:LspInfo` should show:

```
clangd (id: 2)
  - Command: { "clangd", "-j=48", "--clang-tidy=false", "--query-driver=...", ... }
```

Instead of:

```
clangd (id: 2)
  - Command: { "clangd" }  ← This was the problem!
```

## Key Takeaways

1. **LazyVim is not standalone nvim-lspconfig** - it has its own configuration system
2. **Use `opts` tables, not `config` functions** for LSP server configuration
3. **Put server config in `opts.servers[server_name]`** table
4. **LazyVim handles the actual setup** - you just provide the options
5. **Read LazyVim docs** at https://lazyvim.github.io/plugins/lsp

## Related Files

- **New config**: `~/.config/nvim/lua/plugins/lspconfig-lazyvim.lua`
- **Old config**: `~/.config/nvim/lua/plugins/lspconfig.lua.disabled`
- **LazyVim docs**: https://lazyvim.github.io/plugins/lsp
- **This fix**: `~/.config/nvim/LAZYVIM_CLANGD_FIX.md`

