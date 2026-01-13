# Clangd Configuration Fix - Updated 2026-01-13

## Problem
The clangd LSP configuration in nvim was not being applied correctly. Running `:LspInfo` showed:
- Command: `{ "clangd" }` (missing all custom flags)
- Settings: `{}` (empty)

Expected command should include:
- `-j=48`
- `--clang-tidy=false`
- `--query-driver=...`
- `--background-index`
- `--compile-commands-dir=...`
- `--log=verbose`

## Root Cause

**LazyVim's plugin loading order issue**: The custom clangd configuration in `lpsconfig.lua` was being defined in the `mason_lspconfig.handlers` table, but LazyVim's base lspconfig plugin was loading first and setting up clangd with default settings before the custom handlers could run.

The mason_lspconfig handlers approach works for standalone nvim configs, but in LazyVim, you need to use the `opts.servers` pattern to properly override default LSP configurations.

## Solution

### Updated `nvim/lua/plugins/lpsconfig.lua`

**Changed from**: Configuring clangd in `mason_lspconfig.handlers["clangd"]`
**Changed to**: Configuring clangd in the plugin's `opts.servers` table

```lua
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { ... },
  opts = {
    -- Configure servers here to override LazyVim defaults
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
        },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern(".clangd", "compile_commands.json", ".git")(fname)
            or util.path.dirname(fname)
        end,
      },
    },
  },
  config = function(_, opts)
    -- Setup servers from opts first (this includes our custom clangd config)
    for server_name, server_opts in pairs(opts.servers or {}) do
      local server_config = vim.tbl_deep_extend("force", {
        on_attach = on_attach,
        capabilities = capabilities,
      }, server_opts)
      lspconfig[server_name].setup(server_config)
    end

    -- Then setup mason handlers (skip servers already configured in opts.servers)
    mason_lspconfig.setup({
      handlers = {
        function(server_name)
          if not opts.servers or not opts.servers[server_name] then
            lspconfig[server_name].setup({ ... })
          end
        end,
      },
    })
  end,
}
```

### Key Changes

1. **Moved clangd config to `opts.servers`**: This ensures it's applied before LazyVim's defaults
2. **Setup opts.servers first**: In the config function, we now setup servers from `opts.servers` before mason handlers
3. **Skip already configured servers**: Mason handlers now check if a server was already configured in `opts.servers`
4. **Proper util reference**: Changed to `require("lspconfig.util")` for better scoping

## How to Verify

### 1. Restart Neovim
```bash
# Close all nvim instances and reopen
nvim ~/garage/workspace/ap/src/ar_pkt_trace/ar_pkt_trace.c
```

### 2. Check LSP Status
In nvim, run:
```vim
:LspInfo
```

**Before the fix**, you would see:
```
clangd (id: 2)
  - Command: { "clangd" }
  - Settings: {}
```

**After the fix**, you should see:
```
clangd (id: 2)
  - Command: { "clangd", "-j=48", "--clang-tidy=false", "--query-driver=...", "--background-index", "--compile-commands-dir=...", "--log=verbose" }
  - Root directory: /Users/ajay.kumar/garage/workspace/ap
  - Settings: { ... }
```

### 3. Check Active Client Configuration
In nvim, run:
```vim
:lua vim.print(vim.lsp.get_active_clients()[1].config.cmd)
```

This should print the full command array with all your custom flags.

### 4. Check Clangd Logs
```vim
:lua vim.cmd('e ' .. vim.lsp.get_log_path())
```

Look for messages indicating:
- `.clangd` config file was found and loaded
- `compile_commands.json` was loaded
- Query driver paths were resolved

### 5. Test Configuration
Open a C file in your project and verify:
- No warnings about GCC-specific flags (they should be filtered by `.clangd`)
- Code completion works
- Go-to-definition works
- Diagnostics appear correctly

## Expected Behavior

With this fix, clangd should:
1. ✅ Start with all custom command-line flags
2. ✅ Find and load the `.clangd` configuration file
3. ✅ Remove GCC-specific flags that clang doesn't understand
4. ✅ Suppress warnings about unknown arguments
5. ✅ Use the correct cross-compilation toolchain via `--query-driver`
6. ✅ Load the compile commands database from the specified directory

## Troubleshooting

### If configuration still not working:

1. **Verify the config file was loaded**:
   ```bash
   # Check if lpsconfig.lua has the changes
   cat ~/.config/nvim/lua/plugins/lpsconfig.lua | grep -A 20 "opts = {"
   ```

2. **Clear lazy.nvim cache and restart**:
   ```bash
   rm -rf ~/.local/share/nvim/lazy
   nvim
   # Let plugins reinstall, then restart nvim
   ```

3. **Check for conflicting plugins**:
   ```vim
   :Lazy
   # Look for any clangd-related plugins that might override settings
   ```

4. **Check LSP logs** in nvim:
   ```vim
   :lua print(vim.lsp.get_log_path())
   :e <paste the path>
   ```

5. **Restart LSP**:
   ```vim
   :LspRestart
   ```

6. **Check active client config**:
   ```vim
   :lua vim.print(vim.lsp.get_active_clients())
   ```

## Why This Fix Works

In LazyVim, plugins are loaded in a specific order:
1. LazyVim base plugins (including lspconfig with defaults)
2. User plugins (your custom configs)

When you define LSP servers in `mason_lspconfig.handlers`, they run **after** LazyVim has already set up the servers with defaults. By moving the configuration to `opts.servers` and setting them up **first** in the config function, we ensure your custom settings take precedence.

## Additional Notes

- The `.clangd` config file must be in the project root directory
- The `compile_commands.json` should be generated by your build system
- Clangd will automatically reload if `.clangd` file changes
- Use `:LspRestart` after making changes to the nvim config
- This pattern works for any LSP server you want to customize in LazyVim

