# 🚀 Tmux + Neovim Development Setup

A minimal, beautiful, and intuitive tmux configuration with **improved UI layout** and seamless Neovim integration.

## ✨ Features

- **Improved UI Layout** with bottom status bar and integrated tabs in lualine
- **Beautiful Catppuccin Mocha theme** matching your nvim colorscheme
- **Seamless navigation** between tmux panes and nvim splits
- **Vim-like keybindings** for intuitive workflow
- **Smart copy/paste** integration between tmux and nvim
- **Session management** with automatic restore
- **Enhanced development launcher** for quick project setup
- **Minimal status bar** showing only essential information
- **Integrated tab display** in nvim lualine

## 🎯 Key Bindings

### Tmux Prefix
- **Prefix key**: `Ctrl-a` (instead of default `Ctrl-b`)

### Pane Management
- **Split horizontally**: `Prefix + |`
- **Split vertically**: `Prefix + -`
- **Navigate panes**: `Ctrl-h/j/k/l` (works seamlessly with nvim splits)
- **Resize panes**: `Prefix + H/J/K/L`
- **Close pane**: `Prefix + x`

### Window Management
- **New window**: `Prefix + c`
- **Next window**: `Prefix + n`
- **Previous window**: `Prefix + p`
- **Switch to window**: `Prefix + [0-9]`

### Copy Mode (Vim-like)
- **Enter copy mode**: `Prefix + [`
- **Start selection**: `v`
- **Copy selection**: `y`
- **Paste**: `Prefix + ]`

### Session Management
- **List sessions**: `tmux ls`
- **Attach to session**: `tmux attach -t session_name`
- **Detach from session**: `Prefix + d`

## 🎨 New UI Layout

### **Before vs After:**
```
BEFORE (Top Status - Cluttered):
┌─ 󰘳 myproject ► ajay.kumar     ◄ 󰍹 MacBook ◄ 󰃭 17-Oct-25 ◄ 󰥔 21:15 ─┐
│ ► 1 editor ► ► 2 terminal ► ► 3 git ►                           │
├─────────────────────────────────────────────────────────────────┤
│                     Neovim Content                             │
└─────────────────────────────────────────────────────────────────┘

AFTER (Bottom Status + Integrated Tabs):
┌─────────────────────────────────────────────────────────────────┐
│                     Neovim Content                             │
│                   (Maximum Space!)                             │
├─ mode | branch | file | [1.nvim] 2.zsh 3.git | session | time ─┤
└─ myproject                                            21:15 ───┘
```

### **Key Improvements:**
- ✅ **More screen space** for code (no top status bar)
- ✅ **Integrated tabs** in lualine: `[1.nvim] 2.zsh 3.git`
- ✅ **Minimal bottom status** with just session name + time
- ✅ **Cleaner interface** with less visual clutter

## 🚀 Quick Start

### 1. Start a new development session
```bash
# Add ~/bin to your PATH if not already done
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Start development environment
dev                    # Creates session named "dev" in current directory
dev myproject         # Creates session named "myproject" in current directory
dev myproject ~/code  # Creates session named "myproject" in ~/code directory
```

### 2. What you'll see:
- **Window 1 (nvim)**: Neovim opens with your project
- **Window 2 (zsh)**: Terminal ready for commands
- **Window 3 (git)**: Git operations terminal
- **Lualine tabs**: Shows `[1.nvim] 2.zsh 3.git` in statusline
- **Bottom status**: Just `myproject    21:15`

### 3. Manual tmux usage
```bash
# Start new session
tmux new-session -s mysession

# List all sessions
tmux ls

# Attach to existing session
tmux attach -t mysession

# Install tmux plugins (run inside tmux)
# Press: Prefix + I (capital i)

# Reload config
# Press: Prefix + r
```

## 🔧 What's Installed

### Tmux Plugins (via TPM)
- **tmux-sensible**: Sensible defaults
- **vim-tmux-navigator**: Seamless nvim/tmux navigation
- **tmux-resurrect**: Save/restore sessions
- **tmux-continuum**: Automatic session saving

### Nvim Plugins Added
- **vim-tmux-navigator**: Navigate between nvim splits and tmux panes
- **tmux.nvim**: Enhanced tmux integration with copy/paste sync

## 🎨 Theme

The setup uses **Catppuccin Mocha** theme with improved UI layout:
- **Bottom status bar** with minimal session info and time
- **Integrated tabs** displayed in nvim lualine
- **Beautiful pane borders** with consistent colors
- **Clean, minimal design** focused on content
- **Consistent color scheme** across tmux and nvim

## 📁 Files Created/Modified

- `~/.tmux.conf` - Main tmux configuration with bottom status bar
- `~/.config/nvim/lua/plugins/tmux.lua` - Nvim tmux integration
- `~/.config/nvim/lua/plugins/lualine.lua` - Enhanced with tmux tabs and session info
- `~/bin/dev` - Enhanced development environment launcher script
- `~/bin/project` - Quick project launcher helper
- `IMPROVED_UI_LAYOUT.md` - Documentation for the new UI layout
- `POWERLINE_THEME.md` - Powerline theme customization guide

## 🔄 Installing Tmux Plugins

1. Start tmux: `tmux`
2. Press `Prefix + I` (capital i) to install plugins
3. Wait for installation to complete
4. Press `Prefix + r` to reload configuration

## 💡 Tips

- **Tab Navigation**: Use `Ctrl-a + 1/2/3` to switch windows and see tabs update in lualine
- **Seamless Movement**: Use `Ctrl-h/j/k/l` to navigate between nvim splits and tmux panes
- **Session Management**: Use `tmux ls` to list all sessions, `tmux attach -t name` to connect
- **Integrated Display**: Your nvim lualine shows tmux tabs as `[1.nvim] 2.zsh 3.git`
- **Auto-save**: Sessions are automatically saved every 15 minutes and restored on restart
- **Quick Setup**: Use the `dev` script for instant project environments
- **Mouse Support**: Enabled for easy pane resizing and scrolling
- **Minimal UI**: Bottom status shows only session name and time for clean interface

## 🆘 Troubleshooting

### Plugin installation fails
```bash
# Manually install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reload tmux config
tmux source-file ~/.tmux.conf
```

### Navigation not working
- Make sure you're using `Ctrl-h/j/k/l` (not arrow keys)
- Ensure both tmux and nvim plugins are installed
- Try restarting both tmux and nvim

### Tabs not showing in lualine
- Restart nvim to reload the lualine configuration
- Make sure you're in a tmux session with multiple windows
- Check that tmux is running: `tmux ls`

### Colors look wrong
- Ensure your terminal supports true color
- Check that `TERM` environment variable is set correctly
- Try: `export TERM=screen-256color`

### Dev script syntax error
- Make sure the script has proper permissions: `chmod +x ~/bin/dev`
- Check your PATH includes ~/bin: `echo $PATH | grep bin`
- Reload your shell: `source ~/.zshrc`

## 🎆 Summary

Your tmux + nvim setup now features:

✅ **Improved UI Layout** - Bottom status bar with maximum screen space
✅ **Integrated Tabs** - Tmux windows displayed in nvim lualine
✅ **Minimal Design** - Clean interface focused on your code
✅ **Enhanced Navigation** - Seamless movement between panes and splits
✅ **Smart Automation** - Quick project setup with the `dev` script
✅ **Beautiful Theme** - Consistent Catppuccin colors throughout

Enjoy your beautiful, efficient, and intuitive development environment! 🎉
