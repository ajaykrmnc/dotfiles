# Remote Clangd LSP Configuration for Neovim

## Overview

The clangd LSP configuration has been updated to connect to the remote `ap-remote` server via SSH. This is necessary because:

1. Cross-compilation for Linux/aarch64 is done on the remote machine
2. The binaries work properly on the ap-remote Linux environment
3. Local clangd on macOS cannot properly handle the cross-compilation toolchains

## Configuration

The configuration is in `lua/plugins/lspconfig-lazyvim.lua`:

```lua
clangd = {
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
  },
  ...
}
```

## Prerequisites

### 1. SSH Access
Ensure passwordless SSH access to ap-remote:
```bash
ssh ap-remote
```

Your SSH config (`~/.ssh/config`) should have:
```
Host ap-remote
  HostName ajaykumar-ajaykrarista-2zfg4
  ForwardAgent yes
  User ajay.kumar
```

### 2. Remote Workspace
The workspace must exist at `/home/ajay.kumar/garage/workspace/ap` on ap-remote.

### 3. Remote Clangd
Clangd must be installed on the remote server:
```bash
ssh ap-remote "which clangd"
ssh ap-remote "clangd --version"
```

### 4. Remote Compile Commands
The `compile_commands.json` must exist on the remote server:
```bash
ssh ap-remote "ls /home/ajay.kumar/garage/workspace/ap/compile_commands.json"
```

### 5. Remote .clangd Config
The `.clangd` configuration file should be synced to the remote server to ensure consistent behavior.

## File Synchronization

**Important**: Since clangd runs on the remote server, your local files must be synchronized with the remote workspace. Options:

### Option 1: Manual Sync with rsync
```bash
# Sync local changes to remote
rsync -avz --exclude 'build/' --exclude '.git/' \
  ~/garage/workspace/ap/ \
  ap-remote:/home/ajay.kumar/garage/workspace/ap/

# Sync remote changes to local
rsync -avz --exclude 'build/' --exclude '.git/' \
  ap-remote:/home/ajay.kumar/garage/workspace/ap/ \
  ~/garage/workspace/ap/
```

### Option 2: SSHFS Mount
```bash
# Mount remote workspace locally
mkdir -p ~/mnt/ap-remote
sshfs ap-remote:/home/ajay.kumar/garage/workspace/ap ~/mnt/ap-remote

# Work in the mounted directory
cd ~/mnt/ap-remote
nvim .
```

### Option 3: Work Directly on Remote
Use Neovim's built-in remote editing:
```bash
nvim scp://ap-remote//home/ajay.kumar/garage/workspace/ap/
```

## Testing the Setup

1. Open a C file in the ap workspace:
   ```bash
   cd ~/garage/workspace/ap
   nvim ap/src/some_file.c
   ```

2. Check LSP status in Neovim:
   ```vim
   :LspInfo
   ```

3. You should see clangd connected and running

4. Test LSP features:
   - `gd` - Go to definition
   - `K` - Hover documentation
   - `<leader>ca` - Code actions
   - `<leader>cr` - Rename symbol

## Troubleshooting

### LSP Not Starting
Check if SSH connection works:
```bash
ssh ap-remote "cd /home/ajay.kumar/garage/workspace/ap && clangd --version"
```

### Wrong Remote Path
If the remote workspace path is different, update it in:
- `lua/plugins/lspconfig-lazyvim.lua` (the `--compile-commands-dir` argument)

### Slow Performance
The remote LSP may be slower due to network latency. Consider:
- Using a faster network connection
- Reducing the number of background indexing threads (`-j=` parameter)
- Working directly on the remote server

### View Clangd Logs
In Neovim:
```vim
:LspLog
```

Or check the remote clangd logs on the server.

## Notes

- The `.clangd` config file in `/garage/workspace/ap/.clangd` is used by the remote clangd
- Local clangd settings are ignored since we're using the remote server
- File changes must be synced to the remote server for LSP to see them
- Network latency may affect LSP responsiveness

