# LazyVim Clangd Configuration Fix - 2026-01-14

## The Real Problem

You're using **LazyVim**, which has its own LSP configuration system that was
overriding your custom clangd settings. The previous `lspconfig.lua` file was
using the **standalone nvim-lspconfig pattern** (with
`mason_lspconfig.handlers`), but **LazyVim requires a different approach**
using the `opts.servers` pattern.

## Root Cause

1. **LazyVim imports its own plugins** including LSP configuration from
   `lazyvim.plugins`
2. **LazyVim's LSP plugin loads first** and sets up all LSP servers with
   default settings
3. **Your custom `lspconfig.lua` was using the wrong pattern** - it was trying
   to use `mason_lspconfig.handlers` which doesn't work with LazyVim
4. **LazyVim expects configuration in `opts.servers`** table, not in handlers

## The Solution

### Created New File: `lspconfig-lazyvim.lua`

The new configuration file uses LazyVim's pattern:

```lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = {
          "clangd",
          "-j=48",
          "--clang-tidy=false",
          "--query-driver=/path/to/toolchain-*/bin/*",
          "--background-index",
          "--compile-commands-dir=/path/to/project",
          "--log=verbose",
          "--header-insertion=never",
          "--completion-style=detailed",
          "--pch-storage=memory",
        },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern(".clangd", "compile_commands.json",
            ".git")(fname)
            or util.path.dirname(fname)
        end,
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
        },
      },
    },
  },
}
```

### Key Differences from Standalone nvim-lspconfig

| Standalone Pattern                 | LazyVim Pattern                     |
| ---------------------------------- | ----------------------------------- |
| Uses `config = function()`         | Uses `opts = {}`                    |
| Uses `mason_lspconfig.handlers`    | Uses `opts.servers`                 |
| Manual `lspconfig[server].setup()` | LazyVim handles setup automatically |
| Custom `on_attach` function        | LazyVim provides default keymaps    |
| Manual capabilities setup          | LazyVim handles capabilities        |

## Files Changed

1. **Created**: `~/.config/nvim/lua/plugins/lspconfig-lazyvim.lua` - New
   LazyVim-compatible config
2. **Disabled**: `~/.config/nvim/lua/plugins/lspconfig.lua` →
   `lspconfig.lua.disabled`
3. **Backup**: `~/.config/nvim/lua/plugins/lspconfig.lua.old` - Original file
   backup

## Verification Steps

### 1. Restart Neovim Completely

```bash
# Kill all nvim instances
pkill nvim

# Clear lazy.nvim cache (optional but recommended)
rm -rf ~/.local/share/nvim/lazy/nvim-lspconfig

# Open a C file in your project
nvim ~/garage/workspace/ap/src/ar_pkt_trace/ar_pkt_trace.c
```

### 2. Check LSP Status

In Neovim, run:

```vim
:LspInfo
```

**Expected output:**

```
clangd (id: 2)
- Command: { "clangd", "-j=48", "--clang-tidy=false", "--query-driver=...",
... }
- Root directory: ~/garage/workspace/ap
```

### 3. Run Diagnostic Script

```vim
:luafile ~/.config/nvim/check_clangd_config.lua
```

**Expected output:**

```
✅ Found active clangd client (ID: 2)
✅ Found --query-driver parameter:
--query-driver=/Users/ajay.kumar/garage/workspace/ap/build/export/toolchain-*/bin/*,...
```

### 4. Verify Process

```bash
ps aux | grep clangd
```

Should show clangd running with all the custom flags.

## How LazyVim LSP Configuration Works

1. **LazyVim loads** `lazyvim.plugins` which includes its own LSP
   configuration
2. **Your plugin files** in `lua/plugins/` are loaded and **merged** with
   LazyVim's config
3. **`opts.servers` table** is deep-merged with LazyVim's defaults
4. **LazyVim's LSP plugin** handles the actual `lspconfig.setup()` calls
5. **Custom `cmd` arrays** in `opts.servers[server_name]` override the
   defaults

## Common Issues

### Issue: "module 'schemastore' not found"

If you see this error, it means the schemastore plugin isn't loaded yet when
the config is evaluated. The fix has been applied - the jsonls configuration
was removed from the custom config file since LazyVim handles it by default.

## Troubleshooting

### If it still doesn't work:

1. **Check for conflicting files**:

   ```bash
   ls ~/.config/nvim/lua/plugins/ | grep lsp
   ```

   Make sure only `lspconfig-lazyvim.lua` is active (not `.disabled`)

2. **Clear all caches**:

   ```bash
   rm -rf ~/.local/share/nvim/lazy
   rm -rf ~/.local/state/nvim
   rm -rf ~/.cache/nvim
   ```

3. **Check LazyVim version**:

   ```vim
   :Lazy
   ```

   Look for LazyVim and nvim-lspconfig versions

4. **Enable debug logging**:
   Add to your config:
   ```lua
   vim.lsp.set_log_level("debug")
   ```
   Then check logs:
   ```vim
   :lua vim.cmd('e ' .. vim.lsp.get_log_path())
   ```

## References

- [LazyVim LSP Documentation](https://lazyvim.github.io/plugins/lsp)
- [LazyVim Configuration
  Examples](https://lazyvim.github.io/configuration/examples)
- [clangd --query-driver](https://clangd.llvm.org/guides/system-headers)

## Next Steps

After verifying the fix works:

1. You can delete the old files: `lspconfig.lua.disabled` and
   `lspconfig.lua.old`
2. Update this documentation if you find any issues
3. Test with your actual cross-compilation workflow
