# LSP Configuration for Neovim

This configuration provides comprehensive Language Server Protocol (LSP) support for web development and other programming languages.

## 🚀 Features

### Supported Languages & Tools

#### Web Development
- **TypeScript/JavaScript** (`ts_ls`) - Full IntelliSense, type checking, refactoring
- **HTML** (`html`) - Tag completion, validation
- **CSS/SCSS/Less** (`cssls`) - Property completion, validation
- **Tailwind CSS** (`tailwindcss`) - Class completion and validation
- **Emmet** (`emmet_ls`) - HTML/CSS abbreviation expansion
- **ESLint** (`eslint`) - Linting and code actions
- **JSON** (`jsonls`) - Schema validation and completion

#### Other Languages
- **Lua** (`lua_ls`) - Neovim-optimized configuration
- **Python** (`pyright`) - Type checking and IntelliSense
- **Rust** (`rust_analyzer`) - Full Rust language support
- **Go** (`gopls`) - Go language server
- **C/C++** (`clangd`) - C/C++ language support
- **Bash** (`bashls`) - Shell script support
- **YAML** (`yamlls`) - YAML validation
- **Markdown** (`marksman`) - Markdown language server

## 🔧 Installation

The configuration automatically installs all required LSP servers via Mason. After restarting Neovim:

1. **Automatic Installation**: LSP servers will be installed automatically
2. **Manual Check**: Run `:Mason` to see installation status
3. **LSP Status**: Use `:LspInfo` to check active servers

## ⌨️ Key Bindings

### Navigation
- `gD` - Go to declaration
- `gd` - Go to definition
- `K` - Show hover information
- `gi` - Go to implementation
- `gr` - Show references

### Code Actions
- `<space>rn` - Rename symbol
- `<space>ca` - Code actions
- `<space>f` - Format document
- `<space>D` - Type definition

### Diagnostics
- `<space>e` - Open diagnostic float
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<space>q` - Diagnostic quickfix list

### Workspace
- `<space>wa` - Add workspace folder
- `<space>wr` - Remove workspace folder
- `<space>wl` - List workspace folders

## 🎨 Enhanced Features

### TypeScript/JavaScript
- **Inlay Hints**: Parameter names, types, return types
- **Advanced IntelliSense**: Auto-imports, refactoring
- **Error Reporting**: Real-time type checking

### HTML/CSS
- **Emmet Support**: Fast HTML/CSS generation
- **Tailwind Integration**: Class completion and validation
- **Auto-tag**: Automatic HTML tag closing and renaming

### JSON
- **Schema Validation**: Automatic schema detection for common files
- **IntelliSense**: Property completion based on schemas

## 🔍 Treesitter Integration

Enhanced syntax highlighting and text objects for:
- Web languages (TS, JS, HTML, CSS)
- Programming languages (Python, Rust, Go, C/C++)
- Configuration files (YAML, JSON, TOML)
- Documentation (Markdown)

### Text Objects
- `af`/`if` - Function outer/inner
- `ac`/`ic` - Class outer/inner
- `aa`/`ia` - Parameter outer/inner

### Navigation
- `]m`/`[m` - Next/previous function
- `]]`/`[[` - Next/previous class

## 🛠️ Troubleshooting

### LSP Server Not Starting
1. Check `:LspInfo` for server status
2. Run `:Mason` to verify installation
3. Restart Neovim after installation

### Completion Not Working
- LazyVim uses `blink.cmp` for completion
- LSP servers provide completion sources automatically
- Check `:LspInfo` to ensure server is attached

### Formatting Issues
- Formatting is handled by `conform.nvim` (already configured)
- LSP provides fallback formatting with `<space>f`

### TypeScript Issues
- Ensure `tsconfig.json` exists in project root
- Check TypeScript version compatibility
- Use `:LspRestart` to restart the server

## 📁 File Structure

```
lua/plugins/
├── lpsconfig.lua          # Main LSP configuration
├── treesitter-extra.lua   # Enhanced treesitter setup
├── conform.lua            # Formatting (existing)
└── nvim-lint.lua         # Linting (existing)
```

## 🔄 Updates

The configuration uses Mason for automatic updates. To update LSP servers:

1. Run `:Mason`
2. Navigate to installed servers
3. Press `U` to update all or `u` for individual updates

## 🎯 LazyVim Compatibility

This configuration is designed to work seamlessly with LazyVim:
- Uses LazyVim's default completion system (blink.cmp)
- Extends existing treesitter configuration
- Respects LazyVim's key binding conventions
- Compatible with LazyVim's formatting and linting setup
