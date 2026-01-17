# 🎨 Tmux Powerline Theme Documentation

Your tmux configuration now features a beautiful **Powerline theme** with arrow separators and the Catppuccin Mocha color scheme!

## ✨ What's New

### **Powerline Features:**
- **Arrow separators** (►) between status segments
- **Multi-colored segments** with smooth transitions
- **Icons** for session, hostname, date, and time
- **Enhanced window tabs** with powerline styling
- **Username display** in the status bar

### **Visual Layout:**
```
┌─ Session ─►─ Username ─►                    ◄─ Hostname ─◄─ Date ─◄─ Time ─┐
│ 󰘳 myproject ► ajay.kumar                   ◄ 󰍹 MacBook ◄ 󰃭 17-Oct-25 ◄ 󰥔 21:15 │
├─ Window Tabs ──────────────────────────────────────────────────────────────┤
│ ► 1 editor ► ► 2 terminal ► ► 3 git ►                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Status Bar Segments

### **Left Side (Session Info):**
- **Session Name**: 󰘳 with blue background
- **Username**: Current user with dark gray background
- **Powerline arrows**: Smooth transitions between segments

### **Right Side (System Info):**
- **Hostname**: 󰍹 with orange background
- **Date**: 󰃭 with green background  
- **Time**: 󰥔 with pink background

### **Window Tabs:**
- **Active window**: Blue background with white text
- **Inactive windows**: Gray background with muted text
- **Powerline separators**: Between each window tab

## 🎨 Color Scheme (Catppuccin Mocha)

| Element | Color | Hex Code |
|---------|-------|----------|
| Background | Dark | `#1e1e2e` |
| Session | Blue | `#89b4fa` |
| Username | Dark Gray | `#313244` |
| Hostname | Orange | `#fab387` |
| Date | Green | `#a6e3a1` |
| Time | Pink | `#f38ba8` |
| Text | Light | `#cdd6f4` |

## 🔧 Customization Options

### **Change Colors:**
Edit `~/.tmux.conf` and modify the color codes:

```bash
# Example: Change session color from blue to purple
set -g status-left '#[bg=#cba6f7,fg=#1e1e2e,bold] 󰘳 #S #[bg=#313244,fg=#cba6f7]...'
```

### **Add More Segments:**
```bash
# Add CPU usage to right status
set -g status-right '#[bg=#1e1e2e,fg=#fab387]#[bg=#fab387,fg=#1e1e2e] 󰻠 #(top -l 1 | grep "CPU usage" | awk "{print $3}" | cut -d"%" -f1)% #[bg=#fab387,fg=#a6e3a1]...'
```

### **Change Icons:**
Replace the Unicode icons with your preferred ones:
- Session: 󰘳 → 󰆍 or 
- Hostname: 󰍹 → 󰌢 or 
- Date: 󰃭 → 󰸗 or 
- Time: 󰥔 → 󰅐 or ⏰

### **Modify Window Format:**
```bash
# Simpler window format
set -g window-status-current-format '#[bg=#89b4fa,fg=#1e1e2e,bold] #W '
set -g window-status-format '#[bg=#313244,fg=#cdd6f4] #W '
```

## 🎪 Alternative Color Schemes

### **Gruvbox Dark:**
```bash
# Status bar colors (Gruvbox Dark)
set -g status-style 'bg=#282828,fg=#ebdbb2'

# Left status
set -g status-left '#[bg=#458588,fg=#282828,bold] 󰘳 #S #[bg=#3c3836,fg=#458588]#[bg=#3c3836,fg=#ebdbb2] #(whoami) #[bg=#282828,fg=#3c3836]'

# Right status
set -g status-right '#[bg=#282828,fg=#d79921]#[bg=#d79921,fg=#282828] 󰍹 #h #[bg=#d79921,fg=#98971a]#[bg=#98971a,fg=#282828] 󰃭 %d-%b-%y #[bg=#98971a,fg=#cc241d]#[bg=#cc241d,fg=#282828] 󰥔 %H:%M '
```

### **Nord Theme:**
```bash
# Status bar colors (Nord)
set -g status-style 'bg=#2e3440,fg=#d8dee9'

# Left status
set -g status-left '#[bg=#5e81ac,fg=#2e3440,bold] 󰘳 #S #[bg=#3b4252,fg=#5e81ac]#[bg=#3b4252,fg=#d8dee9] #(whoami) #[bg=#2e3440,fg=#3b4252]'

# Right status
set -g status-right '#[bg=#2e3440,fg=#d08770]#[bg=#d08770,fg=#2e3440] 󰍹 #h #[bg=#d08770,fg=#a3be8c]#[bg=#a3be8c,fg=#2e3440] 󰃭 %d-%b-%y #[bg=#a3be8c,fg=#bf616a]#[bg=#bf616a,fg=#2e3440] 󰥔 %H:%M '
```

## 🚀 Quick Commands

### **Reload Configuration:**
```bash
# Reload tmux config to see changes
tmux source-file ~/.tmux.conf

# Or use the keybinding
Ctrl-a + r
```

### **Test Different Sessions:**
```bash
# Create sessions to see the powerline theme
dev my-project ~/code/my-project
dev website ~/projects/website
dev api ~/work/api
```

### **View Current Configuration:**
```bash
# See current status bar settings
tmux show-options -g status-left
tmux show-options -g status-right
tmux show-options -g window-status-current-format
```

## 🎭 Advanced Customizations

### **Add Git Branch to Status:**
```bash
# Add git branch to right status (requires git in PATH)
set -g status-right '#[bg=#1e1e2e,fg=#a6e3a1]#[bg=#a6e3a1,fg=#1e1e2e] 󰊢 #(cd #{pane_current_path}; git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git") #[bg=#a6e3a1,fg=#fab387]...'
```

### **Add Battery Status (macOS):**
```bash
# Add battery percentage
set -g status-right '#[bg=#1e1e2e,fg=#f9e2af]#[bg=#f9e2af,fg=#1e1e2e] 󰁹 #(pmset -g batt | grep -Eo "[0-9]+%" | head -1) #[bg=#f9e2af,fg=#fab387]...'
```

### **Custom Separators:**
You can use different separator styles:
- Solid arrows: `` (right), `` (left)
- Thin arrows: `` (right), `` (left)  
- Rounded: `` (right), `` (left)
- Flame: `` (right), `` (left)

## 🎨 Your Current Theme

Your tmux now features:
- ✅ **Powerline arrows** for smooth segment transitions
- ✅ **Catppuccin Mocha** color scheme
- ✅ **Beautiful icons** for visual appeal
- ✅ **Multi-segment layout** with session, user, hostname, date, time
- ✅ **Enhanced window tabs** with powerline styling
- ✅ **Consistent theming** with your nvim setup

Enjoy your beautiful new powerline tmux theme! 🎉
