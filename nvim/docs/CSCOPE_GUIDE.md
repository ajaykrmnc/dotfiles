# 🔍 Cscope Integration Guide

Cscope is a powerful code navigation tool for C/C++ projects. This guide explains how to use the `cscope_maps.nvim` integration in your Neovim setup.

## 📋 Prerequisites

### Install Cscope

```bash
# Ubuntu/Debian
sudo apt install cscope

# Fedora/RHEL
sudo dnf install cscope

# macOS
brew install cscope

# Arch Linux
sudo pacman -S cscope
```

## 🚀 Quick Start

### 1. Generate Cscope Database

Navigate to your C/C++ project root and run:

```bash
# Basic database generation
cscope -bqkv -R

# Or use the Neovim command (after opening a C/C++ file)
:Cs db build
```

**Flags explained:**
- `-b` - Build the database only (don't start interactive mode)
- `-q` - Create inverted index for faster searches
- `-k` - Kernel mode (don't search `/usr/include`)
- `-v` - Verbose output
- `-R` - Recurse into subdirectories

### 2. Open Neovim and Navigate

Open any C/C++ file and use the keymaps below!

## ⌨️ Keymaps

All keymaps use `<leader>c` prefix (Space + c by default):

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>cs` | `:Cs find s` | Find all **references** to symbol under cursor |
| `<leader>cg` | `:Cs find g` | Find **global definition** of symbol |
| `<leader>cc` | `:Cs find c` | Find functions **calling** this function |
| `<leader>cd` | `:Cs find d` | Find functions **called by** this function |
| `<leader>ct` | `:Cs find t` | Find **text string** |
| `<leader>ce` | `:Cs find e` | **Egrep** pattern search |
| `<leader>cf` | `:Cs find f` | Find **file** by name |
| `<leader>ci` | `:Cs find i` | Find files that **include** this file |
| `<leader>ca` | `:Cs find a` | Find **assignments** to symbol |
| `<leader>cb` | `:Cs db build` | **Rebuild** cscope database |
| `<leader>cS` | `:CsStackView open down` | Show **caller tree** (who calls this) |
| `<leader>cU` | `:CsStackView open up` | Show **callee tree** (what this calls) |
| `Ctrl-]` | `:Cstag` | Jump to definition (cscope + ctags) |

## 📖 Commands

### Basic Commands

```vim
" Find symbol references
:Cs find s <symbol>
:Cs f s <symbol>        " Short form

" Find global definition
:Cs find g <symbol>

" Use word under cursor (empty symbol)
:Cs find g              " Uses <cword>

" Interactive prompt
:CsPrompt g             " Prompts for symbol
```

### Database Commands

```vim
" Build/rebuild database
:Cs db build

" Add additional database
:Cs db add /path/to/cscope.out

" Add with prefix path (for results from different location)
:Cs db add ~/other_project/cscope.out::/home/code/other_project

" Remove database
:Cs db rm /path/to/cscope.out

" Show all connected databases
:Cs db show
```

### Stack View Commands

```vim
" Show all functions that CALL this function (callers)
:CsStackView open down <symbol>

" Show all functions CALLED BY this function (callees)
:CsStackView open up <symbol>

" Toggle last stack view
:CsStackView toggle
```

**Stack View Keymaps (inside stack window):**
| Key | Action |
|-----|--------|
| `<Tab>` | Toggle/expand child nodes |
| `<CR>` | Jump to symbol location |
| `<C-v>` | Open in vertical split |
| `<C-s>` | Open in horizontal split |
| `q` / `<Esc>` | Close stack view |
| `<C-u>` | Scroll preview up |
| `<C-d>` | Scroll preview down |

## 💡 Tips & Tricks

### Auto-rebuild on Save
The config automatically rebuilds cscope database when you save C/C++ files (if `cscope.out` exists).

### Large Projects
For large codebases, generate database with file list:
```bash
# Create file list
find . -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.hpp" > cscope.files

# Build from file list
cscope -bqkv -i cscope.files
```

### Exclude Directories
```bash
find . \( -path ./build -o -path ./third_party \) -prune -o \
  \( -name "*.c" -o -name "*.h" \) -print > cscope.files
cscope -bqkv -i cscope.files
```

### Multiple Projects
Add multiple databases at runtime:
```vim
:Cs db add ~/project1/cscope.out
:Cs db add ~/project2/cscope.out::/home/user/project2
```

## 🔧 Troubleshooting

### "cscope: command not found"
Install cscope using your package manager (see Prerequisites).

### No results found
1. Ensure `cscope.out` exists: `ls cscope.out`
2. Rebuild database: `:Cs db build`
3. Check database status: `:Cs db show`

### Slow on large codebase
Use `-q` flag for inverted index and limit file scope with `cscope.files`.

## 📊 Workflow Example

```
1. cd ~/my_c_project
2. cscope -bqkv -R              # Generate database
3. nvim src/main.c              # Open file
4. Navigate to a function call
5. <leader>cg                   # Jump to definition
6. <leader>cc                   # Who calls this?
7. <leader>cd                   # What does this call?
8. <leader>cS                   # Visual caller tree
9. Ctrl-o                       # Jump back
```

---
**Happy navigating!** 🚀

