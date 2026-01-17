# Clangd Remote LSP Configuration - Changes Summary

## What Was Changed

Your Neovim LSP configuration has been updated to use clangd running on the remote `ap-remote` server via SSH, instead of running clangd locally.

## Files Modified

### 1. `~/.config/nvim/lua/plugins/lspconfig-lazyvim.lua`
**Changed**: The clangd command to use SSH to connect to ap-remote

**Before**:
```lua
cmd = {
  "clangd",
  "-j=48",
  "--clang-tidy=false",
  "--background-index",
  "--compile-commands-dir=/garage/workspace/ap",
  "--query-driver=/garage/workspace/ap/build/export/toolchain-*/bin/*,...",
  ...
}
```

**After**:
```lua
cmd = {
  "ssh",
  "ap-remote",
  "clangd",
  "-j=48",
  "--clang-tidy=false",
  "--background-index",
  "--compile-commands-dir=/home/ajay.kumar/garage/workspace/ap",
  "--log=verbose",
  "--header-insertion=never",
  "--completion-style=detailed",
  "--pch-storage=memory",
}
```

**Key Changes**:
- Added `"ssh"` and `"ap-remote"` at the beginning of the cmd array
- Changed compile-commands-dir to the remote path: `/home/ajay.kumar/garage/workspace/ap`
- Removed `--query-driver` (not needed on remote Linux machine)
- Added `root_dir` function for proper workspace detection

### 2. `/garage/workspace/ap/.clangd`
**Changed**: Updated comments to reflect remote usage

The configuration flags remain the same, but the comments now indicate this file should be synced to the remote server.

## Files Created

### 1. `~/.config/nvim/REMOTE_CLANGD_SETUP.md`
Comprehensive documentation on:
- Why remote LSP is needed
- Prerequisites and setup requirements
- File synchronization options
- Testing and troubleshooting

### 2. `/garage/workspace/ap/test-remote-clangd.sh`
Test script to verify:
- SSH connection to ap-remote
- Remote workspace exists
- Remote clangd is installed
- Remote compile_commands.json exists
- Remote .clangd config exists

## How It Works

1. When you open a C/C++ file in Neovim, the LSP client starts
2. Instead of running `clangd` locally, it runs `ssh ap-remote clangd ...`
3. The remote clangd server:
   - Reads the remote compile_commands.json
   - Uses the remote .clangd configuration
   - Analyzes code using the proper Linux cross-compilation environment
4. LSP responses are sent back over SSH to your local Neovim

## Next Steps

### 1. Test the Configuration
Run the test script:
```bash
cd ~/garage/workspace/ap
./test-remote-clangd.sh
```

### 2. Sync Files to Remote
Your local files need to be synced to the remote server:
```bash
rsync -avz --exclude 'build/' --exclude '.git/' \
  ~/garage/workspace/ap/ \
  ap-remote:/home/ajay.kumar/garage/workspace/ap/
```

### 3. Restart Neovim
Close and reopen Neovim in the workspace:
```bash
cd ~/garage/workspace/ap
nvim ap/src/some_file.c
```

### 4. Verify LSP is Working
In Neovim:
```vim
:LspInfo
```

You should see clangd connected and running.

### 5. Test LSP Features
- `gd` - Go to definition
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>cr` - Rename symbol

## Important Notes

1. **File Sync Required**: Since clangd runs on the remote server, it only sees files on that server. You must sync your local changes to the remote for LSP to work correctly.

2. **Network Latency**: LSP responses may be slightly slower due to SSH overhead. This is normal.

3. **Remote Path**: The configuration assumes the remote workspace is at `/home/ajay.kumar/garage/workspace/ap`. If different, update the path in `lspconfig-lazyvim.lua`.

4. **SSH Config**: Ensure your `~/.ssh/config` has the `ap-remote` host configured correctly.

## Troubleshooting

If LSP doesn't work:

1. Check SSH connection: `ssh ap-remote`
2. Check remote clangd: `ssh ap-remote "which clangd"`
3. Check remote workspace: `ssh ap-remote "ls /home/ajay.kumar/garage/workspace/ap"`
4. View Neovim LSP logs: `:LspLog`
5. Check if files are synced to remote

See `REMOTE_CLANGD_SETUP.md` for detailed troubleshooting.

