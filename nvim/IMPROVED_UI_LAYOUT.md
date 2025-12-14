# 🎨 Improved UI Layout - Minimal & Clean

Your tmux + nvim setup now features a **much cleaner and more intuitive UI** with better placement and minimal design!

## ✨ What's Changed

### **Before (Top Status Bar - Cluttered):**
```
┌─ 󰘳 myproject ► ajay.kumar                   ◄ 󰍹 MacBook ◄ 󰃭 17-Oct-25 ◄ 󰥔 21:15 ─┐
│ ► 1 editor ► ► 2 terminal ► ► 3 git ►                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                        Neovim Content Area                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### **After (Bottom Status + Integrated Tabs):**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│                        Neovim Content Area                                 │
│                                                                             │
├─ Lualine: mode | branch | filename | [1.nvim] 2.zsh 3.git | session | time ─┤
└─ Tmux: myproject                                                   21:15 ───┘
```

## 🎯 **New UI Layout Features**

### **1. Tmux Status Bar (Bottom - Minimal)**
- **Position**: Bottom of screen (more natural)
- **Content**: Only session name + time
- **Style**: Clean, minimal, no clutter
- **Colors**: Subtle Catppuccin theme

### **2. Nvim Lualine (Integrated Tabs)**
- **Tab Display**: Shows tmux windows as `[1.nvim] 2.zsh 3.git`
- **Current Tab**: Highlighted with brackets `[1.nvim]`
- **Inactive Tabs**: Simple format `2.zsh 3.git`
- **Position**: Middle of lualine for easy visibility

### **3. Clean Visual Hierarchy**
- **Top**: Neovim content (maximum space)
- **Middle**: Lualine with integrated tabs
- **Bottom**: Minimal tmux status

## 🎨 **Visual Examples**

### **Tmux Windows Display in Lualine:**
```
Normal Mode | main | README.md | [1.nvim] 2.zsh 3.git | 󰘳 myproject | UTF-8 | 21:15
```

### **When Switching Windows:**
```
Normal Mode | main | README.md | 1.nvim [2.zsh] 3.git | 󰘳 myproject | UTF-8 | 21:15
```

### **Bottom Tmux Status:**
```
myproject                                                                21:15
```

## 🚀 **How to Use**

### **Start a Project Session:**
```bash
# Your enhanced dev script now creates the perfect layout
dev my-project ~/code/my-project

# Creates:
# - Window 1: nvim (shows as [1.nvim] in lualine)
# - Window 2: zsh (shows as 2.zsh in lualine)  
# - Window 3: git (shows as 3.git in lualine)
```

### **Navigation:**
- **Switch tabs**: `Ctrl-a + 1/2/3` (see changes in lualine)
- **Visual feedback**: Current tab highlighted with brackets
- **Clean status**: Only essential info at bottom

### **Benefits:**
1. **More screen space** for code (no top status bar)
2. **Integrated tabs** in familiar lualine location
3. **Minimal distraction** with clean bottom status
4. **Better UX** with natural bottom placement

## 🎛️ **Customization Options**

### **Change Tab Display Format:**
Edit `lua/plugins/lualine.lua` to modify the `tmux_windows()` function:

```lua
-- Current format: [1.nvim] 2.zsh 3.git
-- Alternative formats:

-- Simple numbers: [1] 2 3
table.insert(windows, string.format("[%s]", window_id))

-- With icons: [󰈔 1] 󰆍 2 󰊢 3  
table.insert(windows, string.format("[󰈔 %s]", window_id))

-- Full names: [1:editor] 2:terminal 3:git
table.insert(windows, string.format("[%s:%s]", window_id, window_name))
```

### **Adjust Tmux Status Bar:**
Edit `~/.tmux.conf`:

```bash
# Hide time completely
set -g status-right ''

# Add more info
set -g status-right '#[bg=#313244,fg=#cdd6f4] %H:%M | #h '

# Change session display
set -g status-left '#[bg=#89b4fa,fg=#1e1e2e,bold] 󰘳 #S '
```

### **Modify Lualine Tab Colors:**
```lua
{
  tmux_windows,
  color = { fg = "#a6e3a1", gui = "bold" }, -- Green instead of blue
  separator = { left = "", right = "" },
},
```

## 🎪 **Alternative Layouts**

### **Option 1: Hide Tmux Status Completely**
```bash
# In ~/.tmux.conf
set -g status off
```
*Shows only lualine with tabs - ultra minimal*

### **Option 2: Move Tabs to Tabline**
```lua
-- In lualine config
tabline = {
  lualine_a = { tmux_windows },
  lualine_b = {},
  lualine_c = {},
  lualine_x = {},
  lualine_y = {},
  lualine_z = { tmux_session },
},
```
*Shows tabs in dedicated top line*

### **Option 3: Compact Tab Format**
```lua
-- Show only numbers: [1] 2 3
if flags and flags:match("*") then
  table.insert(windows, string.format("[%s]", window_id))
else
  table.insert(windows, window_id)
end
```

## 🎯 **Perfect for Your Workflow**

This new layout gives you:

✅ **Maximum code space** - No top status bar clutter  
✅ **Integrated tabs** - Tabs where you expect them (in statusline)  
✅ **Minimal distraction** - Only essential info visible  
✅ **Natural placement** - Status at bottom like most apps  
✅ **Clean aesthetics** - Consistent with your minimal theme  

## 🚀 **Quick Start**

```bash
# 1. Reload configurations (already done)
tmux source-file ~/.tmux.conf

# 2. Start nvim to see lualine changes
nvim

# 3. Start a project session
dev my-project

# 4. Switch between tabs with Ctrl-a + 1/2/3
# 5. Watch the tab display update in lualine!
```

Your UI is now **much cleaner, more intuitive, and perfectly optimized** for development work! 🎉
