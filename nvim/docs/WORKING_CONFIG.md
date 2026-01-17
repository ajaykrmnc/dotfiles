# Working LazyVim Clangd Configuration

**Status**: ✅ Ready to use - All syntax errors fixed

## The Final Working Configuration

File: `~/.config/nvim/lua/plugins/lspconfig-lazyvim.lua`

```lua
-- LSP Configuration for LazyVim
-- This file overrides LazyVim's default LSP configuration
return {
  "neovim/nvim-lspconfig",
  opts = {
    -- Diagnostic configuration
    diagnostics = {
      virtual_text = false,
      signs = true,
      update_in_insert = false,
      severity_sort = true,
    },
    -- LSP Server Settings
    servers = {
      -- Clangd with query-driver for cross-compilation
      clangd = {
        cmd = {
          "clangd",
          "-j=48",
          "--clang-tidy=false",
          "--query-driver=/Users/ajay.kumar/garage/workspace/ap/build/export/toolchain-*/bin/*,/Users/ajay.kumar/garage/workspace/ap/build/export/arm-gnu-toolchain-*/bin/*",
          "--background-index",
          "--compile-commands-dir=/Users/ajay.kumar/garage/workspace/ap",
          "--log=verbose",
          "--header-insertion=never",
          "--completion-style=detailed",
          "--pch-storage=memory",
        },
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

## What This Configuration Does

### Diagnostic Settings

- **`virtual_text = false`**: Disable inline diagnostic messages (cleaner UI)
- **`signs = true`**: Show diagnostic signs in the gutter (errors, warnings, etc.)
- **`update_in_insert = false`**: Don't update diagnostics while typing (less distracting)
- **`severity_sort = true`**: Sort diagnostics by severity (errors first)

### Command Line Flags

1. **`-j=48`**: Use 48 parallel jobs for indexing
2. **`--clang-tidy=false`**: Disable clang-tidy checks (faster)
3. **`--query-driver=...`**: **THE KEY FLAG** - Query cross-compiler for system headers
4. **`--background-index`**: Index files in the background
5. **`--compile-commands-dir=...`**: Location of compile_commands.json
6. **`--log=verbose`**: Detailed logging for debugging
7. **`--header-insertion=never`**: Don't auto-insert headers
8. **`--completion-style=detailed`**: Detailed completion info
9. **`--pch-storage=memory`**: Store precompiled headers in memory

### Init Options

- **`clangdFileStatus`**: Show file indexing status
- **`usePlaceholders`**: Use placeholders in completions
- **`completeUnimported`**: Suggest completions from unimported headers
- **`semanticHighlighting`**: Enable semantic highlighting

## Why This Works with LazyVim

1. **Uses `opts` table**: LazyVim merges this with its defaults
2. **No custom `config` function**: LazyVim handles setup automatically
3. **No `root_dir` function**: LazyVim uses sensible defaults
4. **No `on_attach`**: LazyVim provides default keymaps
5. **No `capabilities`**: LazyVim handles this automatically

## What LazyVim Provides Automatically

- ✅ Root directory detection (looks for .git, compile_commands.json, etc.)
- ✅ LSP keymaps (gd, gr, K, etc.)
- ✅ Capabilities from completion plugins
- ✅ Diagnostic configuration
- ✅ Proper setup order

## Testing the Configuration

### Syntax Test
```bash
nvim --headless -l ~/.config/nvim/test_config_syntax.lua
```

Expected: All tests pass ✅

### Load Test
```bash
nvim --headless -c "lua print('Config loaded')" -c "qall" 2>&1 | grep -i error
```

Expected: No errors

### Runtime Test
```bash
# Open a C file
nvim ~/garage/workspace/ap/src/ar_pkt_trace/ar_pkt_trace.c

# In Neovim, run:
:LspInfo
```

Expected output:
```
clangd (id: 2)
  - Command: { "clangd", "-j=48", "--clang-tidy=false", "--query-driver=...", ... }
  - Root directory: ~/garage/workspace/ap
```

## Errors Fixed

### Error 1: "module 'schemastore' not found"
**Cause**: Trying to require schemastore at config load time  
**Fix**: Removed jsonls configuration (LazyVim handles it)

### Error 2: "vim.fs.dirname" validation error
**Cause**: Custom root_dir function with incorrect usage  
**Fix**: Removed root_dir function (LazyVim provides good defaults)

### Error 3: Configuration ignored
**Cause**: Using standalone nvim-lspconfig pattern with LazyVim  
**Fix**: Changed to LazyVim's `opts.servers` pattern

## File Status

- ✅ **Active**: `lspconfig-lazyvim.lua` (this config)
- ❌ **Disabled**: `lspconfig.lua.disabled` (old standalone config)
- 💾 **Backup**: `lspconfig.lua.old` (original file)

## Next Steps

1. **Restart Neovim**: `pkill nvim`
2. **Open a C file**: `nvim ~/garage/workspace/ap/src/ar_pkt_trace/ar_pkt_trace.c`
3. **Check LSP**: `:LspInfo` should show full command with all flags
4. **Test completion**: Type code and see if autocomplete works
5. **Test navigation**: Use `gd` to go to definition

## Success Indicators

✅ No errors in `:messages`  
✅ `:LspInfo` shows full command with `--query-driver`  
✅ Code completion works  
✅ Go-to-definition works  
✅ No warnings about unknown compiler flags  
✅ System headers are found correctly  

## If You Need to Modify

To change clangd flags, edit this file and modify the `cmd` array:

```lua
cmd = {
  "clangd",
  -- Add or modify flags here
  "--new-flag=value",
},
```

Then restart Neovim: `pkill nvim`

## Related Files

- **Project .clangd**: `~/garage/workspace/ap/.clangd` (filters GCC flags)
- **Compile commands**: `~/garage/workspace/ap/compile_commands.json`
- **Diagnostic script**: `~/.config/nvim/check_clangd_config.lua`

